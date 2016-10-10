From: Chris Caputo <ccaputo@alt.net>
Subject: Re: kernel v4.8: iptables logs are truncated with the 4.8 kernel?
Date: Mon, 10 Oct 2016 18:33:14 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.1610101818110.28174@nacho.alt.net>
References: <CAO9zADwLwLLvxmqiLzxK9A5+--ZnvewMzmUvQ4xdm8HHeFNOsA@mail.gmail.com>
        <Pine.LNX.4.64.1610100627230.28174@nacho.alt.net>
        <CAML_gOeUOrt=-D3VHS2B3B_Q1F2-DAYK95Oxu4FEvfE43hjb3g@mail.gmail.com>
Reply-To: Chris Caputo <ccaputo-dated-1486492395.a541b4@alt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vishwanath Pai <vpai@akamai.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Justin Piszcz <jpiszcz@lucidpixels.com>,
        linux-kernel@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Liping Zhang <zlpnobody@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAML_gOeUOrt=-D3VHS2B3B_Q1F2-DAYK95Oxu4FEvfE43hjb3g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 10 Oct 2016, Liping Zhang wrote:
> 2016-10-10 15:02 GMT+08:00 Chris Caputo <ccaputo@alt.net>:
> >   Program received signal SIGSEGV, Segmentation fault.
> >   0x00007ffff65fd18a in _interp_iphdr (pi=0x617f50, len=0) at ulogd_raw2packet_BASE.c:720
> >
> >   715     static int _interp_iphdr(struct ulogd_pluginstance *pi, uint32_t len)
> >   716     {
> >   717             struct ulogd_key *ret = pi->output.keys;
> >   718             struct iphdr *iph =
> >   719                     ikey_get_ptr(&pi->input.keys[INKEY_RAW_PCKT]);
> >   720             void *nexthdr = (uint32_t *)iph + iph->ihl;
> >
> > I believe 7643507fe8b5bd8ab7522f6a81058cc1209d2585 changed previous
> > behavior by not always copying IP header data to user space.
> >
> > On my machine IPv4 log packets result in a ulogd segfault while IPv6
> > packets do not.  I'm not sure of the cause of the difference.
> >
> > The corresponding userspace commit for the 209d2585 kernel change is:
> >
> >   https://git.netfilter.org/iptables/commit/?id=7070b1f3c88a0c3d4e315c00cca61f05b0fbc882
> >
> > This adds --nflog-size to iptables.  When --nflog-size is used with my
> > iptables NFLOG lines, the ulogd-2.0.5 segfaults cease.
> 
> What numbers did you specify after --nflog-size option?
> --nflog-size 0 or ...? If you want log the whole packet to
> the ulogd, please do not specify this nflog-size option.

Not specifying nflog-size does not appear to log the whole packet...

If "--nflog-size" is unspecified, and the iptables config is left 
unchanged when the kernel is upgraded to 4.8, ulogd-2.0.5 crashes.

If "--nflog-size 0" is used, ulogd-2.0.5 crashes.

If "--nflog-size" is used with size 1 or greater, ulogd-2.0.5 is fine.

> > I'm surprised to see a kernel change cause unexpected userspace segfaults,
> > so further investigation into a kernel fix would seem a good idea.
> 
> According to the original user's manual, nflog-range option was
> designed to be the number of bytes copied to userspace, but
> unfortunately there's a bug from the beginning and it never works,
> i.e. in kernel, it just ignored this option.
> 
> Try to change the current nflog-range option's semantics may
> cause unexpected results(maybe like this ulogd crash) ...
> 
> In order to keep compatibility, Vishwanath introduce a new
> nflog-size option and keep nflog-range unchanged. If you just
> upgrade the kernel, and do not change iptables rules, this
> problem will not happen.

I am reporting that the problem does happen simply with an upgrade to 
kernel 4.8 and no other changes.  When "--nflog-size" is unspecified or 
set to 0, the bug in ulogd-2.0.5 gets triggered.

I agree there is a bug in ulogd-2.0.5 that this kernel change exposed, but 
I am trying to explain that all ulogd users risk this segfault if they 
upgrade to kernel 4.8 and don't either update to a fixed ulogd (possibly 
using your patch below) or an unreleased iptables with iptables config 
changes to implement nflog-size on each NFLOG target.

> So I think this is ulogd's bug, in _interp_iphdr, it try to
> dereference the iphdr pointer before validation check, meanwhile
> this problem does not exist in ipv6 path.  Can you try this patch:
> 
> diff --git a/filter/raw2packet/ulogd_raw2packet_BASE.c
> b/filter/raw2packet/ulogd_raw2packet_BASE.c
> index 8a6180c..fd2665a 100644
> --- a/filter/raw2packet/ulogd_raw2packet_BASE.c
> +++ b/filter/raw2packet/ulogd_raw2packet_BASE.c
> @@ -717,7 +717,7 @@ static int _interp_iphdr(struct ulogd_pluginstance
> *pi, uint32_t len)
>         struct ulogd_key *ret = pi->output.keys;
>         struct iphdr *iph =
>                 ikey_get_ptr(&pi->input.keys[INKEY_RAW_PCKT]);
> -       void *nexthdr = (uint32_t *)iph + iph->ihl;
> +       void *nexthdr;
> 
>         if (len < sizeof(struct iphdr) || len <= (uint32_t)(iph->ihl * 4))
>                 return ULOGD_IRET_OK;
> @@ -734,6 +734,7 @@ static int _interp_iphdr(struct ulogd_pluginstance
> *pi, uint32_t len)
>         okey_set_u16(&ret[KEY_IP_ID], ntohs(iph->id));
>         okey_set_u16(&ret[KEY_IP_FRAGOFF], ntohs(iph->frag_off));
> 
> +       nexthdr = (uint32_t *)iph + iph->ihl;
>         switch (iph->protocol) {
>         case IPPROTO_TCP:
>                 _interp_tcp(pi, nexthdr, len);

I agree this will likely fix ulogd, but this misses the point about the 
new kernel defaulting to a zero size return when it used to return the 
packet.

Thanks,
Chris
