From: Joy Latten <latten@austin.ibm.com>
Subject: Re: when having to acquire an SA, ipsec drops the packet
Date: Mon, 5 Mar 2007 19:47:49 -0600
Message-ID: <200703060147.l261lnjX024435@faith.austin.ibm.com>
Cc: herbert@gondor.apana.org.au, jmorris@namei.org,
	netdev@vger.kernel.org, paul.moore@hp.com, vyekkirala@TrustedCS.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:60168 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965696AbXCFCDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 21:03:47 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l2622X9k006248
	for <netdev@vger.kernel.org>; Mon, 5 Mar 2007 21:02:33 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2623jxJ410386
	for <netdev@vger.kernel.org>; Mon, 5 Mar 2007 19:03:45 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2623iEj023209
	for <netdev@vger.kernel.org>; Mon, 5 Mar 2007 19:03:45 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From: Joy Latten <latten@austin.ibm.com>
>Date: Mon, 05 Feb 2007 14:53:39 -0600
>
>> I can run some tests with this patch and report any results... 
>
>Please check out the two most recent patches I posted:
>
>1) Updated core patch with ipv6 side added.
>2) Fix for thinko noticed by Venkat.

I have been testing this a lot in the lspp kernel.
Plan to test also in upstream kernel.
I am seeing a second ACQUIRE occur while establishing the SAs.

My scenario:
My policy states to use both the ESP and AH protocols (may not
make much sense but this was for testing purposes).  I get double 
SAs with only difference being SPI.

Here is what I see happening... 

1. Trigger first ACQUIRE via ping or netperf.

2. xfrm_lookup() calls xfrm_tmpl_resolv() who calls xfrm_state_find().
   First time around, we need to establish SA, so a minimal SA
   get allocated and put in SAD, timer is set for the minimal SA
   to be ACQUIRED and km_query() gets called.
   
3. xfrm_tmpl_resolv() returns -EAGAIN causing add_wait_queue(&km_waitq, &wait)
   and proceeding code to get called waiting for SA to be established.
   As long as the minimal SA with XFRM_STATE_ACQUIRE is in SAD,
   we keep waiting...
   
4. First set of SAs (one for AH and ESP) for IN direction get inserted in SAD.
 
5. Around the time the set of SAs for OUT direction are to be
   inserted into SAD, I see another ACQUIRE happening.
   
   I have not yet figured out where this second ACQUIRE comes from
   and why it happens. As long as the minimal SA or set of valid outgoing
   SAs exist in SAD, an ACQUIRE should not happen.
   The minimal SA does not get removed from the SAD until the set 
   of SAs for OUT get added and the xfrm_state_lock
   released. And the lock pretty much guarantees no one else can step
   through the SAD until after new SAs are being added...
   and if someone gets the lock to step though SAD before OUT SAs
   are added, minimal SA is still there... 

 6. Since this second ACQUIRE was able to happen, result is identical
    sets of SAs for the traffic stream. SPIs are only difference.
 
 7. Noticed something while pasting log info below.
    Perhaps when outgoing AH SA is added, wake_up(&km_waitq) gets called, 
    lock released, and minimal SA deleted (xfrm_state_add()), 
    xfrm_tmpl_resolv() is called and it looks first for the outgoing
    ESP SA. Since it is not there yet and no minimal SA, then km_query()
    results in an ACQUIRE just before the outgoing ESP SA gets added.

    It would explain why I only see it when both ESP and AH are specified...
    that is if I am thinking correctly... 

Regards,
Joy Latten

>From my log file:

Mar  5 19:10:02 racoon: INFO: initiate new phase 2 negotiation: 9.3.192.210[500]<=>9.3.189.55[500]
Mar  5 19:10:03 racoon: INFO: IPsec-SA established: AH/Transport 9.3.189.55[0]->9.3.192.210[0] spi=137942922(0x838d78a)
Mar  5 19:10:03 racoon: INFO: IPsec-SA established: ESP/Transport 9.3.189.55[0]->9.3.192.210[0] spi=244321490(0xe900cd2)
Mar  5 19:10:03 racoon: INFO: IPsec-SA established: AH/Transport 9.3.192.210[0]->9.3.189.55[0] spi=38721750(0x24ed8d6)
Mar  5 19:10:03 racoon: INFO: initiate new phase 2 negotiation: 9.3.192.210[500]<=>9.3.189.55[500]
Mar  5 19:10:03 racoon: INFO: IPsec-SA established: ESP/Transport 9.3.192.210[0]->9.3.189.55[0] spi=265079770(0xfcccbda)
Mar  5 19:10:05 racoon: INFO: IPsec-SA established: AH/Transport 9.3.189.55[0]->9.3.192.210[0] spi=108627618(0x67986a2)
Mar  5 19:10:05 racoon: INFO: IPsec-SA established: ESP/Transport 9.3.189.55[0]->9.3.192.210[0] spi=182973856(0xae7f5a0)
Mar  5 19:10:05 racoon: INFO: IPsec-SA established: AH/Transport 9.3.192.210[0]->9.3.189.55[0] spi=58486297(0x37c6e19)
Mar  5 19:10:05 racoon: INFO: IPsec-SA established: ESP/Transport 9.3.192.210[0]->9.3.189.55[0] spi=268295215(0xffddc2f)
