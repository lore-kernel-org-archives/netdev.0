From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [RFC PATCH 1/4] net: Add support to netdev ops for changing
	hardware queue MAC and VLAN filters
Date: Wed, 18 Nov 2009 16:33:27 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FA69A337F@rrsmsx501.amr.corp.intel.com>
References: <20091117214923.15119.98918.stgit@localhost.localdomain>
	 <1258573987.2780.20.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA69A3162@rrsmsx501.amr.corp.intel.com>
 <1258586065.2780.31.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:22684 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755335AbZKRXdX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 18:33:23 -0500
In-Reply-To: <1258586065.2780.31.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>Sent: Wednesday, November 18, 2009 3:14 PM
>> Setting a MAC filter doesn't blow away the VLAN filter, or vice-versa. So
>just run 'ip' twice to set the filters. Our hardware does it too, and it
>works fine for me:
>>
>> $ ip link set eth1 queue 1 mac 00:11:22:33:44:55
>> $ ip link set eth1 queue 1 vlan 10
>
>Hmm, this is not what I would expect.  I'm used to filters being defined
>independently of queues in a hash table or CAM.  In that case, setting
>multiple filters pointing to one queue will result in the logical
>disjunction of the filters.  Do I understand correctly that you have
>exactly one of each type of filter per queue, with multiple filters
>interpreted as a logical conjunction?
>

Well, it's weirder than that.

In the case of SR-IOV on our hardware, these filters are perfect - no hash tables are required. (We do use hash tables when we have a bunch of multicast addresses, but that's not what this is about.)

MAC filters deny packets by default, so you won't get anything without a valid MAC filter on the queue.

A queue with no VLAN filters will receive packets from all VLANs, albeit with the tags passed up intact.  So in that sense, the VLAN filters are default-allow.  

However, once you enable any VLAN filter, the hardware starts stripping tags and begins to deny packets by default.

Based on these semantics, the filtering operation that I've described above makes perfect sense.

If I understand you correctly, you'd like to be able to apply both types of filter on a single command line:

$ip link set eth1 queue 1 mac <something> vlan <something>

Obviously, this can be done, but it would complicate the code significantly.

-Mitch
