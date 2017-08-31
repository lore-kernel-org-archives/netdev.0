From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] bridge: add tracepoint in br_fdb_update
Date: Thu, 31 Aug 2017 14:38:14 +0200
Message-ID: <20170831143814.68709334@redhat.com>
References: <1504156693-24692-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
        nikolay@cumulusnetworks.com, f.fainelli@gmail.com, andrew@lunn.ch,
        bridge@lists.linux-foundation.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41766 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751009AbdHaMiV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 08:38:21 -0400
In-Reply-To: <1504156693-24692-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Aug 2017 22:18:13 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This extends bridge fdb table tracepoints to also cover
> learned fdb entries in the br_fdb_update path. Note that
> unlike other tracepoints I have moved this to when the fdb
> is modified because this is in the datapath and can generate
> a lot of noise in the trace output. br_fdb_update is also called
> from added_by_user context in the NTF_USE case which is already
> traced ..hence the !added_by_user check.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  include/trace/events/bridge.h | 31 +++++++++++++++++++++++++++++++
>  net/bridge/br_fdb.c           |  5 ++++-
>  net/core/net-traces.c         |  1 +
>  3 files changed, 36 insertions(+), 1 deletion(-)
> 
> diff --git a/include/trace/events/bridge.h b/include/trace/events/bridge.h
> index 0f1cde0..1bee3e7 100644
> --- a/include/trace/events/bridge.h
> +++ b/include/trace/events/bridge.h
> @@ -92,6 +92,37 @@ TRACE_EVENT(fdb_delete,
>  		  __entry->addr[4], __entry->addr[5], __entry->vid)
>  );
>  
> +TRACE_EVENT(br_fdb_update,
> +
> +	TP_PROTO(struct net_bridge *br, struct net_bridge_port *source,
> +		 const unsigned char *addr, u16 vid, bool added_by_user),
> +
> +	TP_ARGS(br, source, addr, vid, added_by_user),
> +
> +	TP_STRUCT__entry(
> +		__string(br_dev, br->dev->name)
> +		__string(dev, source->dev->name)

I have found that using the device string name is 

(1) slow as it involves strcpy+strlen

 See [1]+[2] where a single dev-name costed me 16 ns, and the base
 overhead of a bpf attached tracepoint is 25 ns (see [3]).

 [1] https://git.kernel.org/davem/net-next/c/e7d12ce121a
 [2] https://git.kernel.org/davem/net-next/c/315ec3990ef
 [3] https://git.kernel.org/davem/net-next/c/25d4dae1a64

(2) strings are also harder to work-with/extract when attaching a bpf_prog

See the trouble I'm in accessing a dev string here napi:napi_poll here:
 https://github.com/netoptimizer/prototype-kernel/blob/103b955a080/kernel/samples/bpf/napi_monitor_kern.c#L52-L58

Using ifindex'es in userspace is fairly easy see man if_indextoname(3).

> +		__array(unsigned char, addr, ETH_ALEN)
> +		__field(u16, vid)
> +		__field(bool, added_by_user)
> +	),
> +
> +	TP_fast_assign(
> +		__assign_str(br_dev, br->dev->name);
> +		__assign_str(dev, source->dev->name);
> +		memcpy(__entry->addr, addr, ETH_ALEN);
> +		__entry->vid = vid;
> +		__entry->added_by_user = added_by_user;
> +	),
> +
> +	TP_printk("br_dev %s source %s addr %02x:%02x:%02x:%02x:%02x:%02x vid %u added_by_user %d",
> +		  __get_str(br_dev), __get_str(dev), __entry->addr[0],
> +		  __entry->addr[1], __entry->addr[2], __entry->addr[3],
> +		  __entry->addr[4], __entry->addr[5], __entry->vid,
> +		  __entry->added_by_user)
> +);

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
