From: jamal <hadi@cyberus.ca>
Subject: Re: Problem with IPSEC tunnel mode
Date: Sat, 23 Apr 2005 13:49:04 -0400
Message-ID: <1114278545.7669.75.camel@localhost.localdomain>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au>
	 <200504221342.10675.wolfgang.walter@studentenwerk.mhn.de>
	 <1114172084.7679.15.camel@localhost.localdomain>
	 <200504221522.49403.wolfgang.walter@studentenwerk.mhn.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
In-Reply-To: <200504221522.49403.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Fri, 2005-22-04 at 15:22 +0200, Wolfgang Walter wrote:
> Am Freitag, 22. April 2005 14:14 schrieb jamal:

> I'm not sure how packets of tunnels ending at a host are treated exactly. 
> Probably the tunnel-packet itself is checked against XFRM_POLICY_IN because 
> its destination is the host itself. Then it gets decrypted if an entry 
> appropriate in the sad in (dst,spi) exists. The inner packet gets extracted 
> and decrypted and is then rerouted.
> 
> I think it is like that because
> 
> * you see those packets twice in PREROUTING (mangle) i.e. for an esp-tunnel: 
> first as esp-packet than the inner decrypted packet. If the inner packet is 
> to be routed, XFRM_POLICY_FWD is relevant, otherwise XFRM_POLICY_IN.
> 

Indeed, you are correct.
So to summarize, 

1) for incoming packets:
->If encrypted: the SAD is consulted based on the header.
Infact if you have an onion of encryptions, then they will all be peeled
first if appropriate.
->If packet determined to be local, XFRM_POLICY_IN is used for checking.
->If packet determined to be forwarded, XFRM_POLICY_FWD is consulted;
packet may be dropped if failure else forwarding XFRM_POLICY_OUT is used
to determine the SA bundle to be used if action is to encrypt. [This is
why i was asking whether FWD and OUT should look similar - why check FWD
then use OUT? I didnt quiet understand Patricks answer].

2) for localy generated packets ->  XFRM_POLICY_OUT is both consulted
for checking and used to determine SA bundle to use.

> But maybe XFRM_POLICY_IN is bypassed for ipsec-packets.
> 

ipsec packets essentially should never see XFRM_POLICY_IN from what i am
gathering until after theyve been decrypted and are determined to be
local.

> I didn't try out transport-mode.
> 

Should be no different. You should see (in tcpdump for example) first
then encypted packet then the decrypted one. I havent tried it though.


> Packets to be routed which are still encrypted here are ipsec-packets which 
> are not destinated or originating from this host. Of course they may came in 
> via a tunnel ending at this host:
> 
> a<--->N1<--->b<----ipsec-tunnel--->c<--->N2<--->d 
> 
> If a communicates with d via esp (tunnel or transportmode) and b and c tunnel 
> all packets between network N1 and N2 via ipsec then, on c, a ipsec packet 
> from a to d would come in via the tunnel packed into another ipsec packet, is 
> extracted from the tunnel packet and is routed to d if XFRM_POLICY_FWD allows 
> esp packets from a to d and XFRM_POLICY_OUT allows unencrypted communication 
> between c and d for esp-packets from a to d.
> 

So to allow pass-through of esp packets from a<->d at c, you will have
to essentially create special policy rules (at FWD and OUT) to basically
just allow if src/dst = a/d, correct?


> spdadd 192.168.2.100 192.168.3.10 any -P in ipsec
>            esp/transport//require
>            ah/transport//require;
> 
> installs both in and fwd rules (in RFC-mode). 

What is "RFC mode"?

> Use option -k for only setting  in rules (RFC only knows IN and OUT rules). 
> This behaviour was added to 
> ipsec-tools. As far as I know earlier kernels had a bug and didn't check fwd 
> ruleset so that setkey and racoon worked by accident under linux.
> 
>
> racoon now behaves like pluto: it inserts always in and fwd rules. Its easier 
> than to check if a in or fwd rule or both is needed. 
> 

I think i am still lost on the desire to have the FWD database. Unless
we are trying to use SPD for firewalling? 

> And no, we do not use setkey any more but ip xfrm (though setkey displays more 
> information, i.e. it tells you if a policy is socket-specific).

Should be fixable in ip xfrm ..

>  Reason is 
> that neither setkey  nor racoon can handle large rule sets. And for most fwd 
> rules we also set an in rule (as pluto does).
> 

Do you know why pfkey doesnt scale? Herbert?

cheers,
jamal
