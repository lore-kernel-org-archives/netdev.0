From: David Gundersen <gundy@iinet.net.au>
Subject: Realtek r8168 slow outbound transfer -  potential fix/workaround
Date: Thu, 14 Jun 2007 00:46:04 +1000
Message-ID: <4670032C.7010803@iinet.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from customer-domains.icp-qv1-irony14.iinet.net.au ([203.59.1.169]:6611
	"EHLO customer-domains.icp-qv1-irony14.iinet.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757614AbXFMOpw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 10:45:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi all,

I've been doing a bit of investigation work into a problem that I've 
been experiencing with the latest available r8168 driver from realtek 
('r8168-8.001.00') & linux kernel 2.6.21.1.

I have been experiencing wierd problems with slow outbound traffic that 
seem to go away if there's traffic coming into the device.  Googling 
seen reports of this in a number of places on the web so I get the 
feeling I'm not alone.

I decided to spend a few hours looking into this and as best I could 
tell it's because back-to-back outbound packets result in the 2nd packet 
being mysteriously dropped.

What I found was that line 2505:

  RTL_W8(TxPoll, NPQ);

in the rtl8168_start_xmit() handler is the part that's telling the NIC 
to kick off the next transfer.

I'm guessing that the signal must be edge triggered because after a few 
checks I noticed that during times of heavy transmission, it was 
possible for the card to still have this bit set from the previous 
packet's transmission request, with the result being that the command to 
kick off the next packets' transmission would be lost. The net effect of 
this was that timeouts & retransmits were occurring further up the 
protocol stack, and I believe that was what was responsible for the 
terrible performance.

Now, on to my workaround. Putting a spin style wait like the following 
in front of the line above seemed to solve the problem for me:


if (RTL_R8(TxPoll) & NPQ) {
     for (i = 20; i > 0; i--) {
      if (!(RTL_R8(TxPoll) & NPQ))
       break;
      udelay(25);
    }
}

...

RTL_W8(TxPoll, NPQ);

This waits for the card to signal that it's dealt with the previous 
packet before telling it to process the next. YMMV.

It would be interesting to hear if other people have similar success 
with the above workaround.  Also, I'm not convinced that having a spin 
style wait is the best solution here - if anybody else is able to offer 
a better solution it'd be great to hear it.


Kind Regards,

Dave.
