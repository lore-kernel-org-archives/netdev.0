From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH]: SAD sometimes has double SAs.
Date: Wed, 28 Mar 2007 09:15:15 -0600
Message-ID: <1175094915.3085.503.camel@faith.austin.ibm.com>
References: <200703232258.l2NMwKqH016994@faith.austin.ibm.com>
	 <1174944899.17953.20.camel@localhost.localdomain>
	 <20070326.144843.72708308.davem@davemloft.net>
	 <1174957467.3085.461.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, jmorris@namei.org, paul.moore@hp.com,
	vyekkirala@trustedcs.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:40797 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbXC1Pbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 11:31:49 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2SFVnor023723
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 11:31:49 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2SFVmxW093582
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 09:31:48 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2SFVltr016451
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 09:31:48 -0600
In-Reply-To: <1174957467.3085.461.camel@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Last night I browsed the ipsec-tools code and saw places in
racoon where improvement would actually fix this
problem. I am working on a patch and will pursue this 
on the ipsec-tools mailing list.

I apologize for any inconvenience. 
Eric, sorry as I know you already patched lspp kernel
for testing. I strongly think this should be fixed
in userspace. 

The permission check before flushing does still
need to be added to kernel. 

Regards,
Joy
  
On Mon, 2007-03-26 at 19:04 -0600, Joy Latten wrote:
> On Mon, 2007-03-26 at 14:48 -0700, David Miller wrote:
> > From: Eric Paris <eparis@redhat.com>
> > Date: Mon, 26 Mar 2007 17:34:59 -0400
> > 
> > > I'm not at all able to speak on the correctness or validity of the
> > > solution,
> > 
> > Neither am I yet :)
> > 
> > > but shouldn't the ipv6 case be a && not an || like the ipv4
> > > case?  Isn't this going to match all sorts of things?  Did you test this
> > > patch on ipv6 and see it to solve your problem?
> > > 
> > > I'm also not enjoying the formatting in the ipv6 part where the first
> > > time you have the cast on the same time as the object but not the second
> > > part where x->props.saddr.a6 is on its own little line.
> > 
> > Also, I want to understand what is going to tear down these
> > "other direction" fake entries later on?  I think I can review
> > this patch better if I understand that.
> > 
> I am going to refer to the other-direction-placeholder as the "fake"
> entry. And the larval SA that gets created for the new
> spi as result of a GETSPI message as the "real" entry. 
> 
> The fake entry gets created when the real entry does and does not have
> an spi. It shares some of the same properties of a "real" larval SA
> (they are created using same code) and it's state
> is marked as XFRM_STATE_ACQ. The real entry has a timeout. So, should
> IKE negotiation fail, take too long, etc... it will eventually timeout
> and be deleted. So does the fake entry. It will timeout and should be
> eventually deleted. (I will test this part tomorrow for assurance.)
>  
> When the IKE negotiations are successful, xfrm_state_add() and the
> xfrm_state_update() look for larval SAs in that they look for an SA with
> same src, dst, etc... and with state==XFRM_STATE_ACQUIRE. Any that are
> found are deleted and new SA added. This removes the real larval SA, and
> should also remove the fake entry too.     
> 
> Of course, this is all based on my assumption that IKE will install
> two SAs, one for incoming and one for outgoing. 
> 
> Hopefully this answers how fake entries will be removed. 
> Admittedly, I may miss something or didn't understand something
> correctly as I learn the code, so please let me know. 
> There may even be a better solution that I don't readily see. 
> 
> > As it stands, this looks to me like a workaround for an improperly
> > implemented IPSEC daemon.  Joy states it as saying that the current
> > code requires the keying daemon to manage it's SAs, and I wonder
> > whether any other implementation is even valid.
> > 
> My big mouth. :-) But yes, I do think more SA management in 
> userspace would be ideal. 
> 
> This fix will hopefully ensure kernel doesn't send any
> extra acquires regardless. 
> 
> Joy
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
