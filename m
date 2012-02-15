From: Nick Bowler <nbowler@elliptictech.com>
Subject: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Wed, 15 Feb 2012 11:37:48 -0500
Message-ID: <20120215163748.GA3998@elliptictech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="82I3+IH0IqGh5yIs"
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.scalarmail.ca ([98.158.95.75]:32456 "EHLO
	ironport-01.sms.scalar.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752722Ab2BOQiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 11:38:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi folks,

We were testing IPsec with large mtu sizes (9000 bytes) and noticed the
occasional failure with large datagrams (requiring several fragments,
>=25k bytes or so).  Investigating further, I was able to reproduce the
issue without using IPsec at all.  Looking at the wireshark capture I
see that one of the fragments transmitted is totally bogus: portions of
the payload data have made it onto the wire as the headers.  My test
case was this:

  ping -c 1 -s 30000 -p 42 birch

which is split into 4 frames, 3 of which (first, second and last) look
correct but the fourth consists entirely of 0x42 octets, including the
ethernet and IP headers (so the source address is 42:42:42:42:42:42, the
destination address is 42:42:42:42:42:42, ethertype is 0x4242, etc.)
I've attached the wireshark capture (gzipped) since it's small enough.
Nevertheless, the total length is correct for the missing fragment.

It seems to be specific to the particular network chipset on this
machine (using the r8169 driver):

  Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 03)

because the other machine (which has a Marvell controller) transmits
fine as far as I can tell.  I'll see about putting a discrete network
card in this computer to see if that helps any.

It's not entirely consistent in how things fail.  Sufficiently small
pings (say, <=20k bytes) seem to work 100% of the time, sufficiently
large pings (say, >= 40k bytes) seem to fail 100% of the time, and in
between most pings fail but the occasional one makes it through.
Everything works at all sizes with 1500 byte MTU.

There are no unusual messages in dmesg and this was all run with latest
Linus' git as of this morning.  It occurred with somewhat older kernels
(2.6.39) as well, even though the driver only let me go to 7200 byte mtu
on that version.

Let me know if you need any more info,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)

--82I3+IH0IqGh5yIs
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="fragment-9000.cap.gz"
Content-Transfer-Encoding: base64

H4sICATTO08AA2ZyYWdtZW50LTkwMDAuY2FwAO3dTUhUURjG8fdMMjPqWE6L8IZK5JQwCEna
IkU9oygENi6GIIwJCgJnChQx2miZC/MjdKfRKhvFITDCSohcjIYUrjQqqZXmKsGEWgQG3ebO
YISBbRKp/j94OasLh7u5PJyHe149Gx+ySYpsME0RFV/nX5bWvah1yNE8SYwcct/MLpu8P5Nv
NDqlWvI8wdAB0apmJBZN9cXnuFPeTrguirKeHAvZpRIAAAAAAAAAAAAAAAD4i1k9mPDJrRs0
nvNaVVZtNGh2escAAAAAAAAAAAAAgH+T/NF/OGw+/3ZlB0MZh7VqusH5N4DNrAaN+VODZqf3
AwAAtrI93+rCmtupC7t+JIhMGfa906LtF9zJBOF8Lvu6Sx4X+r0Zn17vbc+yL5c/EVHKmSb7
fenG+767DRVVC+UDEu06tfJx6dKkuz3tSqB1fjWnvrEz99ajnj3hL8Oe00UHzbEHd8yvRcb4
5amzLeETc8VRe/3i1UhDa2dHQc6091zfvfWgHqo1WpqyArGO68eMb6NPi4/0Bs70fyh983mm
bS3/YfNsoO1aRMRat+NdAAAAAAAAAAAA4H9kNWhK/A7xuiQxdPAAAAAA/GotnhwWBx3it0li
kpkhmR/iySFm0zomolWk2UoNVnpIVym7rRtkuRsWv/Md7jM5Q3Z4AAA=

--82I3+IH0IqGh5yIs--
