From: "Chris Audley" <chris@navaho.co.uk>
Subject: IPSec + large packets being corrupted
Date: Thu, 22 Jun 2006 15:32:02 +0100 (BST)
Message-ID: <50741.10.0.0.10.1150986722.squirrel@10.0.0.1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from office.navaho.co.uk ([83.67.67.1]:57239 "HELO mail.navaho.co.uk")
	by vger.kernel.org with SMTP id S1751804AbWFVObH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 10:31:07 -0400
Received: from  ([127.0.0.1])
	by mail.navaho.co.uk (envelope-from chris@navaho.co.uk)
	(Navaho_iCAT_4.0.1-1) with SMTP id 1150909876
	for netdev@vger.kernel.org; Thu, 22 Jun 2006 15:32:03 +0100 (BST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I've been using the 2.6 kernel ipsec system for some time and have always
had to work around issues with large packets not traversing the VPN by
setting the LAN interface MTU size to something like 1400.

Because I always thought this was a hack and not a proper fix, I've spent
a few days trying to work out exactly why large packets aren't traversing
the VPN and have found something which may well be the cause. I really
don't know the kernel networking code that well so I was hoping that
someone can either verify that what I've found is really an issue, or
whether I'm doing something wrong.

This has been seen in the field with P4/e100+e1000 systems running 2.6.12
and in testing on Geode/dp8381x systems running 2.6.17, all using IPv4.
VPN is Racoon based, using x509 certs and ESP/AH (3DES/SHA1).


This is my understanding of how large packets get corrupted:

Large packet (eg. 1600 byte ping) received by VPN server A.
Packet encrypted and fragmented then sent from Server A to Server B.
Packet received by network subsytem on B and frag_list created
ah_input() strips the AH header -- frag sizes are not changed!
esp_input() decrypts data
ip_fragment() uses existing frag_list sizes from before the AH
  header being stripped, and sends too much data (16 bytes extra). This
  breaks the checksum and packets get dropped by destination host.

By setting the MTU on the local interface, this breaks one of the
checks for using the pre-existing frag list in ip_fragment() (MTU is now
smaller than the largest frag size), so the packet fragments are
re-generated from scratch and the large packet gets through.

If I disable the valid frag_list check in ip_fragment(), again large
packets traverse the VPN with no problems at all since the fragments are
re-generated from scratch.

If my analysis of the above is correct, then my feeling is that either
ah_input() should re-calculate the fragment sizes, or some flag should be
set to tell ip_fragment() to use the slow method and recreate the
fragments.

Does this sound like a real problem, or have I missed something obvious?

Regards,
-- 
Chris Audley             mailto:chris@navaho.co.uk








