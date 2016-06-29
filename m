From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 08/16] net/devlink: Add E-Switch mode control
Date: Wed, 29 Jun 2016 12:44:48 +0300
Message-ID: <3d3d8861-3181-124c-3786-cfa39bdce50c@mellanox.com>
References: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
 <1467043649-28594-9-git-send-email-saeedm@mellanox.com>
 <577211E2.90802@gmail.com>
 <28223ec8-f105-d598-39ad-5dc93598dc64@mellanox.com>
 <5772A397.3010905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Tal Anker <Ankertal@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0057.outbound.protection.outlook.com ([157.55.234.57]:3920
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750878AbcF2Jo7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 05:44:59 -0400
In-Reply-To: <5772A397.3010905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/28/2016 7:19 PM, John Fastabend wrote:
> On 16-06-28 03:25 AM, Or Gerlitz wrote:
>> On 6/28/2016 8:57 AM, John Fastabend wrote:
>>
> hmm so in the hardware I have there is actually a l2 table and various
> other tables so I don't have any issue with doing table setup. I would
> like to see a table_create/table_delete/table_show devlink commands at
> some point though but I'm not there yet. This would allow users to
> optimize the table slices if they cared to. But that is future work
> IMO. Certainly not needed in this series at least.

Agree that we could do that and agree that we need not do that now, as 
was agreed (...) in Seville,we are not yet to the geography (== HW 
tables and table graph) advertisement and setup class.


>
>> The offloads mode needs to create a black hole miss rule and
>> send-to-vport rules and create the tables so they can contain later
>> rules set by the kernel in a way which is HW/driver dependent.
> Agreed a black hole miss rule needs to be applied but rather than apply
> it automatically with some toggle I would prefer to just add a 'tc' rule
> for this. Or alternatively it can be added by configuring flooding
> ports so that only a single port is in the flooding mode. This could
> all be done via 'bridge fdb ...' and 'bridge link ...' today I believe.
> Then the user defines the state and not the driver writer. It really is
> cleaner in my opinion.

The black hole serves for throwing packets arriving from **anywhere** 
and not matched to any other HW rule towards the CPU where the e-switch 
manager runs.  Hence, it would be correct in my opinion to have it set 
by the e-switch manager and it means when some API/knob is applied on 
PCI device and not network device, so tc and Co will not really serve 
nicely for that.

> And send-to-vport rules I'm not entirely clear on what these actually
> are used for. Is this a rule to match packets sent from a VF representer
> netdev to the actual VF pcie device? If this is the case its seems to
> me that any packet sent on a VF representer should be sent to the VF
> directly and these rules can be created when the VF is created. Or did
> you mean some other rule by this?

YES, send-to-vports rule serve for having the functionality which is 
described in the cover letter and on the relevant commit/s: doing xmit 
on VF rep netdevice always ends up with the packet to arrive the VF PCI 
device. We create these HW rules when in the offloads mode per each 
VF/rep indeed.

So when a driver SRIOV logic wakes up in offloads mode (hopefully will 
happen a lot soon...), they would (1) create VF reps (2) set these 
rules, sure.  Currently a transition from legacy to offloads is defined 
and these two acts are than on the transition, e.g for mlx5 whose 
current default is legacy.

Or.
