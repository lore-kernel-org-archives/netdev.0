From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next] net: ixgbe: Fix cls_u32 offload
 support for ports and fields with masks.
Date: Fri, 04 Mar 2016 12:41:53 -0800
Message-ID: <56D9F311.7060402@gmail.com>
References: <1457120869-3489-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Sridhar Samudrala <sridhar.samudrala@intel.com>,
	intel-wired-lan@lists.osuosl.org, john.r.fastabend@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35826 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759618AbcCDUmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 15:42:07 -0500
Received: by mail-pf0-f193.google.com with SMTP id x188so1554855pfb.2
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 12:42:07 -0800 (PST)
In-Reply-To: <1457120869-3489-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-04 11:47 AM, Sridhar Samudrala wrote:
> Fix support for 16 bit source/dest port matches in ixgbe model.
> u32 uses a single 32-bit key value for both source and destination ports
> starting at offset 0. So replace the 2 functions with a single function
> that takes this key value/mask to program both source and dest ports.
> 
> Remove the incorrect check for mask in ixgbe_configure_clsu32()
> 
> Tested with the following filters:
> 
>  #tc qdisc add dev p4p1 ingress
>  #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
> 	handle 800:0:1 u32 ht 800: \
> 	match ip dst 11.0.0.1/24 match ip src 11.0.0.2/24 action drop
> 
>  #tc filter del dev p4p1 parent ffff: protocol ip prio 99 \
> 	handle 800:0:1 u32
>  #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
> 	handle 1: u32 divisor 1
>  #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
> 	handle 800:0:10 u32 ht 800: link 1: \
> 	offset at 0 mask 0f00 shift 6 plus 0 eat match ip protocol 6 ff
>  #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
> 	handle 1:0:10 u32 ht 1: \
> 	match tcp src 1024 ffff match tcp dst 80 ffff action drop
> 
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> ---

But this will break setting only dst port or only src port. Do we
actually need three signatures to match? Something like,

  static struct ixgbe_mat_field ixgbe_tcp_fields[] = {
	{.off = 0, .mask = 0xffffffff, .val = ixgbe_mat_prgm_ports,
  	 .type = IXGBE_ATR_FLOW_TYPE_TCPV4},
	{.off = 0, .mask = 0xffff0000, .val = ixgbe_mat_prgm_dport,
  	 .type = IXGBE_ATR_FLOW_TYPE_TCPV4},
	{.off = 0, .mask = 0x0000ffff, .val = ixgbe_mat_prgm_sport,
  	 .type = IXGBE_ATR_FLOW_TYPE_TCPV4},
  	{ .val = NULL } /* terminal node */
  };

Also just a reminder if we get multiple fields in a ixgbe_mat_field
struct we need to abort out of the for loop in the cls_u32 configure
function. Actually we can probably just push that as its own patch
to make the core function more versatile/usable.

Thanks,
John
