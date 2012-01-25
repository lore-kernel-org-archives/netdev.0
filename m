From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Wed, 25 Jan 2012 11:14:33 +0100
Message-ID: <201201251114.34774.hans.schillstrom@ericsson.com>
References: <1326448338-13416-1-git-send-email-hans.schillstrom@ericsson.com> <201201241856.11732.hans.schillstrom@ericsson.com> <20120124181540.GA2063@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans@schillstrom.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:57381 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab2AYKOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 05:14:38 -0500
In-Reply-To: <20120124181540.GA2063@1984>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 24 January 2012 19:15:40 Pablo Neira Ayuso wrote:
> On Tue, Jan 24, 2012 at 06:56:10PM +0100, Hans Schillstrom wrote:
> > On Monday 23 January 2012 18:01:50 Pablo Neira Ayuso wrote:
> > > Hi Hans,
> > > 
> > > On Mon, Jan 23, 2012 at 10:49:16AM +0100, Hans Schillstrom wrote:
> > > > On Monday 23 January 2012 10:12:41 Pablo Neira Ayuso wrote:
> > > > > On Mon, Jan 23, 2012 at 12:20:15AM +0100, Hans Schillstrom wrote:
> > > > > > The text should clarify that this is valid for the fragments not the "flow"
> > > > > > 
> > > > > > > I've got one scenario that may break with this assumption:
> > > > > > > 
> > > > > > > 1) your traffic follows one path over router A and B to reach your
> > > > > > >    firewall F which requires no fragmentation at all.
> > > > 
> > > > I missed the last part here  "requires no fragmentation at all"
> > > > 
> > > > > > > 2) path to router B becomes broken while there are established flows
> > > > > > >    with firewall F.
> > > > > > > 3) router A decides to forward packets to router C, which fragment
> > > > > > >    packets because it is using smaller MTU than router A.
> > > > > > > 4) packets arrive to firewall F, then hashing is calculated based on
> > > > > > >    addresses, not ports, and you load-sharing becomes inconsistent.
> > > > > > > 
> > > > > > > This can rarely happen, but it does, it would break.
> > > > > > > 
> > > > > > > To fix this, I think that HMARK requires that you have to specify the
> > > > > > > hashing strategy. If you want to support fragments, use only
> > > > > > > addresses. If you're sure you will not get fragments, use layer 3 and
> > > > > > > layer 4 information.
> > > > 
> > > > This can be acomplished by setting --hmark-sp-mask and --hmark-dp-mask to Zero
> > > > Then you don't use port in the hash calc.
> > > 
> > > OK, it would be great if we can provide a cleaner interface. The
> > > current behaviour uses layer3-layer4 tuple hashing plus defaulting to
> > > layer3 in case of fragments.
> > > 
> > > I'd prefer explicit configuration options:
> > > 
> > > --hashmark-method layer3
> > >         use only address for hashing, this is fragment safe.
> > > 
> > > --hashmark-method layer3-layer4
> > >         use addresses and ports for hashing, fragments not supported
> > >         unless defrag is enabled.
> > > 
> > > Still, if you want to support the current behaviour, it should be
> > > something like:
> > > 

We skip this option, 
fragments can be catched by iptables rules and feeded to a HMARK rule
with --hmark-method L3 option
It's more clear.

> > > --hashmark-method layer3-layer4-fragments
> > >         use addresses and ports for hashing, for fragments default to
> > >         layer3 hashing. Document scenario in which hash consistency
> > >         may break.
> > > 
> > > The behaviour of the target has to be specified by the configurations.
> > > Defaulting to internal assumptions seems obscure to me.
> > > 
> > OK this is resonable, and it makes the fragment problem visible.
> > 
> > I'll make the changes to day and have a test run for a couple of days.
> 
> Fine, thanks Hans.

Here is help text and man page just to clarify the changes:
Is this clear enough ?

HMARK target options, i.e. modify hash calculation by:
  --hmark-method <method>            Overall L3/L4 and fragment behavior
                 L3                  Fragment safe, do not use ports or protocol
                                     i.e  Fragments don't need special care.

                 L3-4 (Default)      Fragment unsafe, use ports and protocol
                                     if defrag is off in conntrack
                                        no hmark produced on any part of fragments.
  Limit/modify the calculated hash mark by:
  --hmark-mod value                  nfmark modulus value
  --hmark-offs value                 Last action add value to nfmark

 Fine tuning of what will be included in hash calculation
  --hmark-smask length               Source address mask length
  --hmark-dmask length               Dest address mask length
  --hmark-sp-mask value              Mask src port with value
  --hmark-dp-mask value              Mask dst port with value
  --hmark-spi-mask value             For esp and ah AND spi with value
  --hmark-sp-set value               OR src port with value
  --hmark-dp-set value               OR dst port with value
  --hmark-spi-set value              For esp and ah OR spi with value
  --hmark-proto-mask value           Mask Protocol with value
  --hmark-rnd                        Initial Random value to hash cacl.
 For NAT in IPv4 the original address can be used in the return path.
 Make sure to qualify the statement in a proper way when using nat flags
  --hmark-dnat                       Replace src addr with original dst addr
  --hmark-snat                       Replace dst addr with original src addr
 In many cases hmark can be omitted i.e. --smask can be used


MAN PAGE

   HMARK
       This module does the same as MARK, i.e. set an fwmark, but the mark is based on a hash value.
       The hash is based on saddr, daddr, sport, dport and proto. The same mark will be produced independent 
       of direction if no masks is set or the same masks is used for src and dest.
       The hash mark could be adjusted by modulus and finally an offset could be added, i.e the final mark will
       be within a range.  ICMP error will use the the original message for hash calculation not the icmp it self.

       Note: None of the parameters effect the packet it self only the calculated hash value.
             IPv4 packets with nf_defrag_ipv4 loaded will be defragmented before they reach hmark,
             IPv6 nf_defrag is not implemented this way, hence fragmented ipv6 packets will reach hmark.
             Default behavior is to completely ignore any fragment if it reach hmark.
             --hmark-method L3 is fragment safe since neither ports or L4 protocol is used.
             

       Parameters: Short hand methods

       --hmark-method L3
              Do not use proto, ports or spi, only Layer 3 addresses, mask length of L3 addresses can still be used.  
              Fragment or not does not matter in this case since only L3 address can be used in calc. of hash value.

       --hmark-method L3-4
              Default method, Include L4 in calc. of hash value i.e. all masks below are valid.
              Fragments will be ignored. (i.e no hash value produced)

       For all masks default is all "1:s", to disable a field use mask 0 

       --hmark-smask length
              The length of the mask to AND the source address with (saddr & value).

       --hmark-dmask length
              The length of the mask to AND the dest. address with (daddr & value).

       --hmark-sp-mask value
              A 16 bit value to AND the src port with (sport & value).

       --hmark-dp-mask value
              A 16 bit value to AND the dest port with (dport & value).

       --hmark-sp-set value
              A 16 bit value to OR the src port with (sport | value).

       --hmark-dp-set value
              A 16 bit value to OR the dest port with (dport | value).

       --hmark-spi-mask value
              Value to AND the spi field with (spi & value) valid for proto esp or ah.

       --hmark-spi-set value
              Value to OR the spi field with (spi | value) valid for proto esp or ah.

       --hmark-proto-mask value
              An 8 bit value to AND the L4 proto field with (proto & value).

       --hmark-rnd value
              A 32 bit initial value for hash calc, default is 0xc175a3b8.

       Final processing of the mark in order of execution.

       --hmark-mod value (must be > 0)
              The easiest way to describe this is:  hash = hash mod <value>

       --hmark-offs value
              The easiest way to describe this is:  hash = hash + <value>

       Examples:

       Default rule handles all TCP, UDP, SCTP, ESP & AH

              iptables -t mangle -A PREROUTING -j HMARK --hmark-offs 10000 --hmark-mod 10

       Handle SCTP and hash dest port only and produce a nfmark between 100-119.

              iptables -t mangle -A PREROUTING -p SCTP -j HMARK --smask 0 --dmask 0 \
               --sp-mask 0 --offs 100 --mod 20

       No defragment by conntrack, None Fragments will have fwmark 100-119 
       Fragments will have fwmark 120-139 (based on saddr and daddr only)

              iptables -t mangle -A PREROUTING -j HMARK --method L3-4 --mod 20 --offs 100
              iptables -t mangle -A PRROUTING -m mark --mark 0 -j HMARK --method L3 --mod 20 --offs 120

       Fragment safe Layer 3 only that keep a class C netw together

              iptables -t mangle -A PREROUTING -j HMARK --method L3 --smask 24 --mod 20 --offs 100


-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
