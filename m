From: Michal Sekletar <msekleta@redhat.com>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Fri, 6 Mar 2015 10:04:13 +0100
Message-ID: <20150306090413.GC2841@morgoth.brq.redhat.com>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com>
 <54F77336.7040006@plumgrid.com>
 <20150305103715.GA3432@morgoth.brq.redhat.com>
 <54F889EB.7000203@plumgrid.com>
 <54F8B680.4050307@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>, guy@alum.mit.edu,
	atzm@stratosphere.co.jp
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57791 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753495AbbCFJEo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 04:04:44 -0500
Content-Disposition: inline
In-Reply-To: <54F8B680.4050307@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 05, 2015 at 09:03:12PM +0100, Daniel Borkmann wrote:
> On 03/05/2015 05:52 PM, Alexei Starovoitov wrote:
> >On 3/5/15 2:37 AM, Michal Sekletar wrote:
> >>On Wed, Mar 04, 2015 at 01:03:50PM -0800, Alexei Starovoitov wrote:
> >>>On 3/4/15 12:41 PM, Michal Sekletar wrote:
> >>>>This commit introduces new BPF extension. It makes possible to load value of
> >>>>skb->vlan_proto (vlan tpid) to register A.
> >>>>
> >>>>Currently, vlan header is removed from frame and information is available to
> >>>>userspace only via tpacket interface. Hence, it is not possible to install
> >>>>filter which uses value of vlan tpid field.
> >>>>
> >>>>AFAICT only way how to filter based on tpid value is to reconstruct original
> >>>>frame encapsulation and interpret BPF filter code in userspace. Doing that is
> >>>>way slower than doing filtering in kernel.
> >>>>
> >>>>Cc: Alexei Starovoitov <ast@plumgrid.com>
> >>>>Cc: Jiri Pirko <jpirko@redhat.com>
> >>>>Signed-off-by: Michal Sekletar <msekleta@redhat.com>
> >>>>---
> >>>>@@ -282,6 +282,7 @@ Possible BPF extensions are shown in the following table:
> >>>>    vlan_tci                              skb_vlan_tag_get(skb)
> >>>>    vlan_pr                               skb_vlan_tag_present(skb)
> >>>>    rand                                  prandom_u32()
> >>>>+  vlan_proto                            skb->vlan_proto
> >>>
> >>>the patch is correct and looks clean, but I don't understand
> >>>the motivation for the patch.
> >>
> >>Way how libpcap currently uses BPF extensions is not compatible with old
> >>behavior where actual value of tpid field was checked. I wanted to address
> >>that, i.e. if "vlan" keyword is used as filter expression, libpcap should
> >>install a filter such that only ethernet frames having tpid value of 0x8100 or
> >>0x9100 will pass. That is not the case with current libpcap git and 4.0-rc1
> >>kernel.
> >>
> >>Given that I broke libpcap as described above I tried to come up with the way
> >>how to fix that. However I realized that with recent kernels there is no other
> >>way than adding new BPF extension.
> >>
> >>>There is already SKF_AD_VLAN_TAG_PRESENT. If it is set then only
> >>>two possible values of vlan_proto are ETH_P_8021Q or ETH_P_8021AD.
> >>
> >>Any reason why ETH_P_QINQ1, ETH_P_QINQ2, ETH_P_QINQ3 no longer works? If I
> >>understand correctly, you are basically saying, that there is no point checking
> >>for vlan tpid because PF_PACKET socket will never receive frame having other
> >>tpid value than above two anyway.
> >>
> >>So bottom line is that I wanted to grant userspace programs more flexibility,
> >>and you are saying that it is pointless because for example if outer tpid is
> >>0x9100 socket will never receive the frame. If that is the case then
> >>disregard the patch.
> >
> >steering towards vlan device happens only for ETH_P_8021Q and
> >ETH_P_8021AD. Non-standard 0x9100 and other tags won't be popped into
> >skb metadata and will stay as-is in the packet body.
> >If the meaning of 'vlan 100' in libpcap is to detect all possible
> >vlan tpid then bpf program would need to check VLAN_TAG_PRESENT
> >(that would mean vlan_proto is either 0x8100 or 0x88A8)
> >and parse packet body for tpids 0x9[123]00.
> >Whether we add access to skb->vlan_proto or not, the program would
> >still need to do the above steps, but instead of checking for
> >vlan_tag_present only, it would need to do vlan_proto==0x8100
> >or vlan_proto=0x88a8 and then parse the packet for tpid=0x9[123]00
> >so adding access to vlan_proto will not simplify libpcap job.
> 
> +1, libpcap would, of course, need to check for both, the offloaded
> and non-offloaded case. I'm not sure if you're already doing this or
> plan to fix it there, Michal?

On recent kernels libpcap now checks only offloaded case. I have an intention to
fix this. Do you mind being Cc'ed on PR once submitted?

Michal

> 
> >At this point I think it's up to Dave to decide whether we need
> >this patch (after fixing the issue pointed by Denis) or not.
> >imo there is a benefit of giving programs more visibility into
> >skb metadata.
> 
> I'm not really a big fan of it, but given we added commit a0cdfcf39362
> ("packet: deliver VLAN TPID to userspace") to packet sockets ...
> 
> Michal, please make sure in v2 that you Cc related JIT people.
> 
> In case you're sending v2, please fix up bpf_asm in the following way:
> 
> I don't like the vlan_{pr,proto} ... it's confusing, so lets add a
> better alias and keep compatibility with vlan_pr. Here's the chunk:
> 
> diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
> index 9930ecfb..d9a2080 100644
> --- a/Documentation/networking/filter.txt
> +++ b/Documentation/networking/filter.txt
> @@ -279,8 +279,9 @@ Possible BPF extensions are shown in the following table:
>    hatype                                skb->dev->type
>    rxhash                                skb->hash
>    cpu                                   raw_smp_processor_id()
> +  vlan_avail                            skb_vlan_tag_present(skb)
>    vlan_tci                              skb_vlan_tag_get(skb)
> -  vlan_pr                               skb_vlan_tag_present(skb)
> +  vlan_proto                            skb->vlan_proto
>    rand                                  prandom_u32()
> 
>  These extensions can also be prefixed with '#'.
> diff --git a/tools/net/bpf_exp.l b/tools/net/bpf_exp.l
> index 833a966..c1a1a39 100644
> --- a/tools/net/bpf_exp.l
> +++ b/tools/net/bpf_exp.l
> @@ -90,8 +90,10 @@ extern void yyerror(const char *str);
>  "#"?("hatype")	{ return K_HATYPE; }
>  "#"?("rxhash")	{ return K_RXHASH; }
>  "#"?("cpu")	{ return K_CPU; }
> -"#"?("vlan_tci") { return K_VLANT; }
>  "#"?("vlan_pr")	{ return K_VLANP; }
> +"#"?("vlan_avail") { return K_VLANP; }
> +"#"?("vlan_tci") { return K_VLANT; }
> +"#"?("vlan_proto") { return K_VLANPR; }
>  "#"?("rand")	{ return K_RAND; }
> 
>  ":"		{ return ':'; }
> diff --git a/tools/net/bpf_exp.y b/tools/net/bpf_exp.y
> index e6306c5..d4c749c 100644
> --- a/tools/net/bpf_exp.y
> +++ b/tools/net/bpf_exp.y
> @@ -56,7 +56,7 @@ static void bpf_set_jmp_label(char *label, enum jmp_type type);
>  %token OP_LDXI
> 
>  %token K_PKT_LEN K_PROTO K_TYPE K_NLATTR K_NLATTR_NEST K_MARK K_QUEUE K_HATYPE
> -%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_POFF K_RAND
> +%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_VLANPR K_POFF K_RAND
> 
>  %token ':' ',' '[' ']' '(' ')' 'x' 'a' '+' 'M' '*' '&' '#' '%'
> 
> @@ -167,6 +167,9 @@ ldb
>  	| OP_LDB K_RAND {
>  		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
>  				   SKF_AD_OFF + SKF_AD_RANDOM); }
> +	| OP_LDB K_VLANPR {
> +		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
> +				   SKF_AD_OFF + SKF_AD_VLAN_PROTO); }
>  	;
> 
>  ldh
> @@ -218,6 +221,9 @@ ldh
>  	| OP_LDH K_RAND {
>  		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
>  				   SKF_AD_OFF + SKF_AD_RANDOM); }
> +	| OP_LDH K_VLANPR {
> +		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
> +				   SKF_AD_OFF + SKF_AD_VLAN_PROTO); }
>  	;
> 
>  ldi
> @@ -274,6 +280,9 @@ ld
>  	| OP_LD K_RAND {
>  		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
>  				   SKF_AD_OFF + SKF_AD_RANDOM); }
> +	| OP_LD K_VLANPR {
> +		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
> +				   SKF_AD_OFF + SKF_AD_VLAN_PROTO); }
>  	| OP_LD 'M' '[' number ']' {
>  		bpf_set_curr_instr(BPF_LD | BPF_MEM, 0, 0, $4); }
>  	| OP_LD '[' 'x' '+' number ']' {
