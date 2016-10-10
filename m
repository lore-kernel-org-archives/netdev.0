From: Chris Caputo <ccaputo@alt.net>
Subject: Re: kernel v4.8: iptables logs are truncated with the 4.8 kernel?
Date: Mon, 10 Oct 2016 07:02:39 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.1610100627230.28174@nacho.alt.net>
References: <CAO9zADwLwLLvxmqiLzxK9A5+--ZnvewMzmUvQ4xdm8HHeFNOsA@mail.gmail.com>
Reply-To: Chris Caputo <ccaputo-dated-1486450960.58a944@alt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Justin Piszcz <jpiszcz@lucidpixels.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Vishwanath Pai <vpai@akamai.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAO9zADwLwLLvxmqiLzxK9A5+--ZnvewMzmUvQ4xdm8HHeFNOsA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 4 Oct 2016, Justin Piszcz wrote:
> kernel 4.8 with ulogd-2.0.5- IPs are no longer logged:
> 
> Oct  4 17:51:30 atom INPUT_BLOCK IN=eth1 OUT=
> MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 LEN=0 TOS=00 PREC=0x00
> TTL=0 ID=0 PROTO=0 MARK=0
> Oct  4 17:51:31 atom INPUT_BLOCK IN=eth1 OUT=
> MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 LEN=0 TOS=00 PREC=0x00
> TTL=0 ID=0 PROTO=0 MARK=0
> Oct  4 17:51:32 atom INPUT_BLOCK IN=eth1 OUT=
> MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 LEN=0 TOS=00 PREC=0x00
> TTL=0 ID=0 PROTO=0 MARK=0
> 
> (reboot back to kernel 4.7, works fine)
> 
> kernel 4.7 with ulogd-2.0.5:
> Oct  4 17:56:44 atom INPUT_BLOCK IN=eth1 OUT=
> MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 SRC=74.125.22.125
> DST=1.2.3.4 LEN=397 TOS=00 PREC=0x00 TTL=48 ID=58093 PROTO=TCP
> SPT=5222 DPT=19804 SEQ=2032644254 ACK=2273184383 WINDOW=55272 ACK PSH
> URGP=0 MARK=0
> Oct  4 17:56:45 atom INPUT_BLOCK IN=eth1 OUT=
> MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 SRC=74.125.22.125
> DST=1.2.3.4 LEN=397 TOS=00 PREC=0x00 TTL=48 ID=58725 PROTO=TCP
> SPT=5222 DPT=19804 SEQ=2032644254 ACK=2273184383 WINDOW=55272 ACK PSH
> URGP=0 MARK=0
> 
> Looks like there were some changes in the 4.8 kernel regarding ulogd,
> has anyone else run into this problem?

For me, kernel 4.8.1 results in segfaults in ulogd-2.0.5 at:

  Program received signal SIGSEGV, Segmentation fault.
  0x00007ffff65fd18a in _interp_iphdr (pi=0x617f50, len=0) at ulogd_raw2packet_BASE.c:720

  715     static int _interp_iphdr(struct ulogd_pluginstance *pi, uint32_t len)
  716     {
  717             struct ulogd_key *ret = pi->output.keys;
  718             struct iphdr *iph =
  719                     ikey_get_ptr(&pi->input.keys[INKEY_RAW_PCKT]);
  720             void *nexthdr = (uint32_t *)iph + iph->ihl;

I believe 7643507fe8b5bd8ab7522f6a81058cc1209d2585 changed previous 
behavior by not always copying IP header data to user space.

On my machine IPv4 log packets result in a ulogd segfault while IPv6 
packets do not.  I'm not sure of the cause of the difference.

The corresponding userspace commit for the 209d2585 kernel change is:

  https://git.netfilter.org/iptables/commit/?id=7070b1f3c88a0c3d4e315c00cca61f05b0fbc882

This adds --nflog-size to iptables.  When --nflog-size is used with my 
iptables NFLOG lines, the ulogd-2.0.5 segfaults cease.

I'm surprised to see a kernel change cause unexpected userspace segfaults, 
so further investigation into a kernel fix would seem a good idea.  
Having to add the likes of "--nflog-size 200" (200 simply being what I am 
using) to every NFLOG line in firewall configs is a significant burden for 
many.

Putting out a new release of iptables may help ease this transition if the 
kernel is not patched to fix this.  I had to use the git code since 1.6.0 
doesn't have it.

Chris
