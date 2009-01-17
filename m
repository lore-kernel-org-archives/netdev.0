From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe: Replace LRO with GRO
Date: Sat, 17 Jan 2009 01:07:46 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365F59F11A11@rrsmsx501.amr.corp.intel.com>
References: <20090113092625.GA28015@gondor.apana.org.au>
 <20090113092828.GA28052@gondor.apana.org.au>
 <20090114084412.GA17393@gondor.apana.org.au>
 <20090115034619.GA28267@gondor.apana.org.au>
 <9929d2390901161532j57528215mdb01f38be1bd4c7f@mail.gmail.com>
 <20090117003629.GA22370@gondor.apana.org.au>
 <EA929A9653AAE14F841771FB1DE5A1365F59F11911@rrsmsx501.amr.corp.intel.com>
 <20090117034510.GA23714@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50044 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755528AbZAQIIH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2009 03:08:07 -0500
In-Reply-To: <20090117034510.GA23714@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Jan 16, 2009 at 06:06:18PM -0700, Tantilov, Emil S wrote:
>> See attached.
> 
> Thanks Emil!
> 
> However, it's not very clear who is the sender in this case :)
> 
> FTP has a separate data connection, so the sender of the control
> connection is not necessarily the sender of the data connection.
> 
> In fact, looking at the dump of the data connection it'd appear
> that the one you marked as the sender dump is in fact the receiver
> for the data connection:

The test is done by a script that:

1. checks the connection to the secondary system (ping)
2. copies the test file to the secondary test system (put)
3. copies the same file again from the secondary to the test system (get)
4. Compares the checksum of the sent vs. the received file

Since I had tcpdump on both ends - I think you should see both session in each. The file I named sender (probably a bit incorrect) is just the capture taken from the primary test system (the one that started the script). This is also the system on which I have the latest git with GRO.

> 12:07:17.045244 IP (tos 0x8, ttl 64, id 19084, offset 0, flags [DF],
> proto TCP (6), length 1500) 190.0.15.1.9504 > 190.0.15.3.41206: .
> 1:1449(1448) ack 1 win 46 <nop,nop,timestamp 199022661 4897363>
> 12:07:17.045260 IP (tos 0x8, ttl 64, id 15863, offset 0, flags [DF],
> proto TCP (6), length 52) 190.0.15.3.41206 > 190.0.15.1.9504: .,
> cksum 0x72a1 (correct), ack 1449 win 69 <nop,nop,timestamp 4897363
> 199022661>     
> 
> We can see that because the delta between the data and the ack
> is much smaller on this side.
> 
> It's also peculiar that there seems to be no GRO aggregation
> at all on either side.  Were these dumps taken with it enabled
> on both sides? You'll need a patched ethtool to check.

No only one of the systems (the sender) runs the latest git with GRO. The secondary test system runs on stock RHEL5.2 kernel.

> The transfer itself appears to be encountering a lot of packet loss,
> which presumably caused a premature end which is why you saw a
> missing chunk in the file.
> 
> However, it is not very clear what is causing this loss.  BTW,
> did you apply the fix b0059b50b70dc3a908bea4ece2f9494a22200018
> (gro: Fix page ref count for skbs freed normally) on both sides?
> That one is required to make igb or ixgbe work properly.
Ah - doesn't seem like I have this fix. Jeff will have to pull this in our test tree.

 
> Another thing to try is to disable GSO/TSO on both sides as that
> is complicating the interpretation of the dumps.
Will do if the fix above doesn't help.

Thanks,
Emil
