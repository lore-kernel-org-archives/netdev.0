From: Wei-Chun Chao <weichunc@plumgrid.com>
Subject: Re: [PATCH net-next] ipv4: fix tunneled VM traffic over hw VXLAN/GRE
 GSO NIC
Date: Wed, 18 Dec 2013 17:51:25 -0800
Message-ID: <CACviX4H9L7TFXCvhaxUxkpMR+jPU02BrQAby2BbS+b0earxDbQ@mail.gmail.com>
References: <1387393368-1028-1-git-send-email-weichunc@plumgrid.com>
	<20131218163533.21a16709@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem <davem@davemloft.net>,
	"eric.dumazet" <eric.dumazet@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	netdev <netdev@vger.kernel.org>,
	"joseph.gasparakis" <joseph.gasparakis@intel.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f176.google.com ([209.85.128.176]:62552 "EHLO
	mail-ve0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486Ab3LSBv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 20:51:26 -0500
Received: by mail-ve0-f176.google.com with SMTP id oz11so282911veb.21
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 17:51:25 -0800 (PST)
In-Reply-To: <20131218163533.21a16709@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 4:35 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 18 Dec 2013 11:02:48 -0800
> Wei-Chun Chao <weichunc@plumgrid.com> wrote:
>
>> This is also seen on 'net'.
>>
>> VM to VM GSO traffic is broken if it goes through VXLAN or GRE
>> tunnel and the physical NIC on the host supports hardware VXLAN/GRE
>> GSO offload (e.g. bnx2x and next-gen mlx4).
>>
>> Two issues -
>> (VXLAN) VM traffic has SKB_GSO_DODGY and SKB_GSO_UDP_TUNNEL with
>> SKB_GSO_TCP/UDP set depending on the inner protocol. GSO header
>> integrity check fails in udp4_ufo_fragment if inner protocol is
>> TCP. Also gso_segs is calculated incorrectly using skb->len that
>> includes tunnel header. Fix: robust check should only be applied
>> to the inner packet.
>>
>> (VXLAN & GRE) Once GSO header integrity check passes, NULL segs
>> is returned and the original skb is sent to hardware. However the
>> tunnel header is already pulled. Fix: tunnel header needs to be
>> restored so that hardware can perform GSO properly on the original
>> packet.
>>
>> Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>
>> ---
>
> Is there someway the tunnel could fixup the GSO bits?

Thanks, Stephen.

You meant handling DODGY bit (and unsetting it) before GRE and VXLAN
encap? I guess we can do

    if (skb_shinfo(skb)->gso_type & SKB_GSO_DODGY) {
        skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
        skb_shinfo(skb)->gso_type &= ~(SKB_GSO_DODGY);
    }


in handle_offloads(vxlan.c) and gre_handle_offloads(gre.h). We will
save the overhead to pull and push the tunnel header later. Though
since skb->dev is not known at this time yet, this will be done
unconditionally unlike before (done only when skb_gso_ok return true).

Weichun
