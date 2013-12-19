From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] ipv4: fix tunneled VM traffic over hw
 VXLAN/GRE GSO NIC
Date: Wed, 18 Dec 2013 18:05:18 -0800
Message-ID: <20131218180518.43b2f242@nehalam.linuxnetplumber.net>
References: <1387393368-1028-1-git-send-email-weichunc@plumgrid.com>
	<20131218163533.21a16709@nehalam.linuxnetplumber.net>
	<CACviX4H9L7TFXCvhaxUxkpMR+jPU02BrQAby2BbS+b0earxDbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem <davem@davemloft.net>,
	"eric.dumazet" <eric.dumazet@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	netdev <netdev@vger.kernel.org>,
	"joseph.gasparakis" <joseph.gasparakis@intel.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Wei-Chun Chao <weichunc@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:51254 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab3LSCFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 21:05:22 -0500
Received: by mail-pd0-f180.google.com with SMTP id q10so454828pdj.39
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 18:05:21 -0800 (PST)
In-Reply-To: <CACviX4H9L7TFXCvhaxUxkpMR+jPU02BrQAby2BbS+b0earxDbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Dec 2013 17:51:25 -0800
Wei-Chun Chao <weichunc@plumgrid.com> wrote:

> On Wed, Dec 18, 2013 at 4:35 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > On Wed, 18 Dec 2013 11:02:48 -0800
> > Wei-Chun Chao <weichunc@plumgrid.com> wrote:
> >
> >> This is also seen on 'net'.
> >>
> >> VM to VM GSO traffic is broken if it goes through VXLAN or GRE
> >> tunnel and the physical NIC on the host supports hardware VXLAN/GRE
> >> GSO offload (e.g. bnx2x and next-gen mlx4).
> >>
> >> Two issues -
> >> (VXLAN) VM traffic has SKB_GSO_DODGY and SKB_GSO_UDP_TUNNEL with
> >> SKB_GSO_TCP/UDP set depending on the inner protocol. GSO header
> >> integrity check fails in udp4_ufo_fragment if inner protocol is
> >> TCP. Also gso_segs is calculated incorrectly using skb->len that
> >> includes tunnel header. Fix: robust check should only be applied
> >> to the inner packet.
> >>
> >> (VXLAN & GRE) Once GSO header integrity check passes, NULL segs
> >> is returned and the original skb is sent to hardware. However the
> >> tunnel header is already pulled. Fix: tunnel header needs to be
> >> restored so that hardware can perform GSO properly on the original
> >> packet.
> >>
> >> Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>
> >> ---
> >
> > Is there someway the tunnel could fixup the GSO bits?
> 
> Thanks, Stephen.
> 
> You meant handling DODGY bit (and unsetting it) before GRE and VXLAN
> encap? I guess we can do
> 
>     if (skb_shinfo(skb)->gso_type & SKB_GSO_DODGY) {
>         skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
>         skb_shinfo(skb)->gso_type &= ~(SKB_GSO_DODGY);
>     }
> 
> 
> in handle_offloads(vxlan.c) and gre_handle_offloads(gre.h). We will
> save the overhead to pull and push the tunnel header later. Though
> since skb->dev is not known at this time yet, this will be done
> unconditionally unlike before (done only when skb_gso_ok return true).
> 
> Weichun

I was hoping more that generic tunnel code could just do software UFO/GSO
for now, and when somebody has hardware that handles nested GSO they could
provide a feature flag mechanism.
