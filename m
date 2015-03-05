From: Michal Sekletar <msekleta@redhat.com>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Thu, 5 Mar 2015 11:37:15 +0100
Message-ID: <20150305103715.GA3432@morgoth.brq.redhat.com>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com>
 <54F77336.7040006@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755156AbbCEKhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 05:37:25 -0500
Content-Disposition: inline
In-Reply-To: <54F77336.7040006@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 04, 2015 at 01:03:50PM -0800, Alexei Starovoitov wrote:
> On 3/4/15 12:41 PM, Michal Sekletar wrote:
> >This commit introduces new BPF extension. It makes possible to load value of
> >skb->vlan_proto (vlan tpid) to register A.
> >
> >Currently, vlan header is removed from frame and information is available to
> >userspace only via tpacket interface. Hence, it is not possible to install
> >filter which uses value of vlan tpid field.
> >
> >AFAICT only way how to filter based on tpid value is to reconstruct original
> >frame encapsulation and interpret BPF filter code in userspace. Doing that is
> >way slower than doing filtering in kernel.
> >
> >Cc: Alexei Starovoitov <ast@plumgrid.com>
> >Cc: Jiri Pirko <jpirko@redhat.com>
> >Signed-off-by: Michal Sekletar <msekleta@redhat.com>
> >---
> >@@ -282,6 +282,7 @@ Possible BPF extensions are shown in the following table:
> >    vlan_tci                              skb_vlan_tag_get(skb)
> >    vlan_pr                               skb_vlan_tag_present(skb)
> >    rand                                  prandom_u32()
> >+  vlan_proto                            skb->vlan_proto
> 
> the patch is correct and looks clean, but I don't understand
> the motivation for the patch.

Way how libpcap currently uses BPF extensions is not compatible with old
behavior where actual value of tpid field was checked. I wanted to address
that, i.e. if "vlan" keyword is used as filter expression, libpcap should
install a filter such that only ethernet frames having tpid value of 0x8100 or
0x9100 will pass. That is not the case with current libpcap git and 4.0-rc1
kernel.

Given that I broke libpcap as described above I tried to come up with the way
how to fix that. However I realized that with recent kernels there is no other
way than adding new BPF extension.

> There is already SKF_AD_VLAN_TAG_PRESENT. If it is set then only
> two possible values of vlan_proto are ETH_P_8021Q or ETH_P_8021AD.

Any reason why ETH_P_QINQ1, ETH_P_QINQ2, ETH_P_QINQ3 no longer works? If I
understand correctly, you are basically saying, that there is no point checking
for vlan tpid because PF_PACKET socket will never receive frame having other
tpid value than above two anyway.

So bottom line is that I wanted to grant userspace programs more flexibility,
and you are saying that it is pointless because for example if outer tpid is
0x9100 socket will never receive the frame. If that is the case then
disregard the patch.

> If there another vlan header inside the packet, it's AD.
> So you can do the filtering already without adding new bpf extension...

Cheers,

Michal
