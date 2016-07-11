From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v6 02/12] net: add ndo to set xdp prog in adapter rx
Date: Mon, 11 Jul 2016 12:35:34 +0200
Message-ID: <57837676.3010900@iogearbox.net>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com> <1467944124-14891-3-git-send-email-bblanco@plumgrid.com> <CALx6S36-ccirAZBbHCNO3hHeuW32tSwNPcxz5oevp90fzm+BOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>
To: Tom Herbert <tom@herbertland.com>,
	Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59012 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932286AbcGKKfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 06:35:40 -0400
In-Reply-To: <CALx6S36-ccirAZBbHCNO3hHeuW32tSwNPcxz5oevp90fzm+BOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2016 10:59 PM, Tom Herbert wrote:
> On Thu, Jul 7, 2016 at 9:15 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
>> Add two new set/check netdev ops for drivers implementing the
>> BPF_PROG_TYPE_XDP filter.
>>
>> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
>> ---
>>   include/linux/netdevice.h | 14 ++++++++++++++
>>   net/core/dev.c            | 30 ++++++++++++++++++++++++++++++
>>   2 files changed, 44 insertions(+)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 49736a3..36ae955 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -63,6 +63,7 @@ struct wpan_dev;
>>   struct mpls_dev;
>>   /* UDP Tunnel offloads */
>>   struct udp_tunnel_info;
>> +struct bpf_prog;
>>
>>   void netdev_set_default_ethtool_ops(struct net_device *dev,
>>                                      const struct ethtool_ops *ops);
>> @@ -1087,6 +1088,15 @@ struct tc_to_netdev {
>>    *     appropriate rx headroom value allows avoiding skb head copy on
>>    *     forward. Setting a negative value resets the rx headroom to the
>>    *     default value.
>> + * int (*ndo_xdp_set)(struct net_device *dev, struct bpf_prog *prog);
>> + *     This function is used to set or clear a bpf program used in the
>> + *     earliest stages of packet rx. The prog will have been loaded as
>> + *     BPF_PROG_TYPE_XDP. The callee is responsible for calling bpf_prog_put
>> + *     on any old progs that are stored, but not on the passed in prog.
>> + * bool (*ndo_xdp_attached)(struct net_device *dev);
>> + *     This function is used to check if a bpf program is set on the device.
>> + *     The callee should return true if a program is currently attached and
>> + *     running.
>>    *
>>    */
>>   struct net_device_ops {
>> @@ -1271,6 +1281,9 @@ struct net_device_ops {
>>                                                         struct sk_buff *skb);
>>          void                    (*ndo_set_rx_headroom)(struct net_device *dev,
>>                                                         int needed_headroom);
>> +       int                     (*ndo_xdp_set)(struct net_device *dev,
>> +                                              struct bpf_prog *prog);
>> +       bool                    (*ndo_xdp_attached)(struct net_device *dev);
>
> It might nice if everything could be accomplished with with one ndo
> function (just too many ndo's flying around). Also, may want to
> consider future like maybe we have an XDP function in output path, or
> multiple programs pipelined together somehow.

You could probably have it roughly similar to ndo_setup_tc where you pass
commands down to the driver, if it should just be one central ndo, good
thing is that this is not set in stone anyway.

For pipelining, you'd most likely use tail calls, so you just have the root
program passed here, which is fine already as-is, since the rest for it is
handeled by bpf(2).
