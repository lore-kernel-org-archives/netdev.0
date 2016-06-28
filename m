From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 08/16] net/devlink: Add E-Switch mode control
Date: Tue, 28 Jun 2016 13:25:06 +0300
Message-ID: <28223ec8-f105-d598-39ad-5dc93598dc64@mellanox.com>
References: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
 <1467043649-28594-9-git-send-email-saeedm@mellanox.com>
 <577211E2.90802@gmail.com>
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
	Ido Schimmel <idosch@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0074.outbound.protection.outlook.com ([157.55.234.74]:28376
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752709AbcF1MAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 08:00:14 -0400
In-Reply-To: <577211E2.90802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/28/2016 8:57 AM, John Fastabend wrote:
> On 16-06-27 09:07 AM, Saeed Mahameed wrote:
>> Add the commands to set and show the mode of SRIOV E-Switch, two modes are supported:
>>
>> * legacy   : operating in the "old" L2 based mode (DMAC --> VF vport)
>> * offloads : offloading SW rules/policy (e.g Bridge/FDB or TC/Flows based) set by the host OS
>>
>> Nice work overall also I really appreciated that the core networking
>> interfaces appear to able to support this without any change.

thanks..

>> On this patch though do we really need modes like this? My concern with
>> modes is two fold. One its another knob that some controller will have
>> to get right which I would prefer to avoid. And two I suspect switching
>> between the two modes flushes the tables or leaves them in some
>> unexpected state? At least I can't figure out what the expected should
>> be off-hand.

Re the 1st concern (another knob), I think we do want that, see below

Re the 2nd concern, I will re-read the cover letter and change logs and 
if needed clarify/improve: the transition is clean! When you are moving 
from legacy to offloads or the other way around, nothing is left in 
unexpected state,  all HW forwarding tables as filled by the current 
mode are flushed and next they are set as needed for the new mode.

>> Could we instead continue to use the "legacy" mode by default by just
>> populating the fdb table correctly and then if users want to enable
>> the "offloads" mode they can modify the fdb tables by deleting entries
>> or adding them or just extending the dmac/vf mapping via 'tc'. This
>> would seem natural to me. The flooding rules in fdb might need to be
>> exposed a bit more cleanly to get the right default flooding behavior
>> etc. But to me at least this would be much cleaner. Everything will be
>> nicely defined and we wont have issues with drivers doing slightly
>> and subtle different defaults between legacy/offload and the transitions
>> between the states or on resets or etc. If users need to discover the
>> current configuration then they just query fdb, query tc, and the state
>> is known no need for any magic toggle switch as best I can see.


Few comments here:

Each mode has it's own way of the driver doing setup for the HW tables 
and how population of the HW tables is done.

The offloads mode needs to create a black hole miss rule and 
send-to-vport rules and create the tables so they can contain later 
rules set by the kernel in a way which is HW/driver dependent.

The legacy mode creates the tables differently and populates them later 
with rule set by
the driver and not the kernel.

Even if we put the different table setup issue a side, I don't think it 
would be correct for bridge/tc to remove rules they didn't add, which is 
needed under your proposal when moving from legacy type rules to 
offloads mode. Querying is problematic too, since legacy could (and 
does) involve some default rules set by the FW, e.g that deals with 
outer world (== not belonging to VM on this host) MACs which are 
invisible to the driver.

That legacy was here and we can't avoid handling it properly for which 
this knob is needed. Note that a vendor can choose to put their default 
to be offloads, hopefully over time, we will all go there :)

>> Otherwise I didn't review the mlx code but read the commit msgs and
>> it looks good. I'll take a closer look in the morning.

appreciated
