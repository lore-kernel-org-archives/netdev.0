From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] neighbour: update neigh timestamps iff update is
 effective
Date: Mon, 15 May 2017 23:05:24 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1705152234490.4002@ja.home.ssi.bg>
References: <20170510000605.6799-1-ihrachys@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        He Chunhui <hchunhui@mail.ustc.edu.cn>, netdev@vger.kernel.org
To: Ihar Hrachyshka <ihrachys@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55162 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S932677AbdEOUGG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 16:06:06 -0400
In-Reply-To: <20170510000605.6799-1-ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 9 May 2017, Ihar Hrachyshka wrote:

> It's a common practice to send gratuitous ARPs after moving an
> IP address to another device to speed up healing of a service. To
> fulfill service availability constraints, the timing of network peers
> updating their caches to point to a new location of an IP address can be
> particularly important.
> 
> Sometimes neigh_update calls won't touch neither lladdr nor state, for
> example if an update arrives in locktime interval. Then we effectively
> ignore the update request, bailing out of touching the neigh entry,
> except that we still bump its timestamps.
> 
> This may be a problem for updates arriving in quick succession. For
> example, consider the following scenario:
> 
> A service is moved to another device with its IP address. The new device
> sends three gratuitous ARP requests into the network with ~1 seconds
> interval between them. Just before the first request arrives to one of
> network peer nodes, its neigh entry for the IP address transitions from
> STALE to DELAY.  This transition, among other things, updates
> neigh->updated. Once the kernel receives the first gratuitous ARP, it
> ignores it because its arrival time is inside the locktime interval. The
> kernel still bumps neigh->updated. Then the second gratuitous ARP
> request arrives, and it's also ignored because it's still in the (new)
> locktime interval. Same happens for the third request. The node
> eventually heals itself (after delay_first_probe_time seconds since the
> initial transition to DELAY state), but it just wasted some time and
> require a new ARP request/reply round trip. This unfortunate behaviour
> both puts more load on the network, as well as reduces service
> availability.
> 
> This patch changes neigh_update so that it bumps neigh->updated (as well
> as neigh->confirmed) only once we are sure that either lladdr or entry
> state will change). In the scenario described above, it means that the
> second gratuitous ARP request will actually update the entry lladdr.
> 
> Ideally, we would update the neigh entry on the very first gratuitous
> ARP request. The locktime mechanism is designed to ignore ARP updates in
> a short timeframe after a previous ARP update was honoured by the kernel
> layer. This would require tracking timestamps for state transitions
> separately from timestamps when actual updates are received. This would
> probably involve changes in neighbour struct. Therefore, the patch
> doesn't tackle the issue of the first gratuitous APR ignored, leaving
> it for a follow-up.
> 
> Signed-off-by: Ihar Hrachyshka <ihrachys@redhat.com>

	Looks ok to me,

Acked-by: Julian Anastasov <ja@ssi.bg>

	It seems arp_accept value currently has influence on
the locktime for GARP requests. My understanding is that
locktime is used to ignore replies from proxy_arp
routers while the requested IP is present on the LAN
and replies immediately. IMHO, GARP requests should not
depend on locktime, even when arp_accept=0. For example:

	if (IN_DEV_ARP_ACCEPT(in_dev)) {
	...
+	} else if (n && tip == sip && arp->ar_op == htons(ARPOP_REQUEST)) {
+		unsigned int addr_type = inet_addr_type_dev_table(net, dev, sip);
+
+		is_garp = (addr_type == RTN_UNICAST);
	}

> ---
>  net/core/neighbour.c | 14 ++++++++++----
>  1 file changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 58b0bcc..d274f81 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -1132,10 +1132,6 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
>  		lladdr = neigh->ha;
>  	}
>  
> -	if (new & NUD_CONNECTED)
> -		neigh->confirmed = jiffies;
> -	neigh->updated = jiffies;
> -
>  	/* If entry was valid and address is not changed,
>  	   do not change entry state, if new one is STALE.
>  	 */
> @@ -1157,6 +1153,16 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
>  		}
>  	}
>  
> +	/* Update timestamps only once we know we will make a change to the
> +	 * neighbour entry. Otherwise we risk to move the locktime window with
> +	 * noop updates and ignore relevant ARP updates.
> +	 */
> +	if (new != old || lladdr != neigh->ha) {
> +		if (new & NUD_CONNECTED)
> +			neigh->confirmed = jiffies;
> +		neigh->updated = jiffies;
> +	}
> +
>  	if (new != old) {
>  		neigh_del_timer(neigh);
>  		if (new & NUD_PROBE)
> -- 
> 2.9.3

Regards
