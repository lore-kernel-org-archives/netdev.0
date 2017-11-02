From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: Bond recovery from BOND_LINK_FAIL state not working
Date: Wed, 01 Nov 2017 17:35:13 -0700
Message-ID: <10968.1509582913@famine>
References: <f9a6457e-f575-e9c1-2519-7694e30c474f@hpe.com> <28118.1509572045@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Jarod Wilson <jarod@redhat.com>
To: Alex Sidorenko <alexandre.sidorenko@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:50465 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932433AbdKBAfU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 20:35:20 -0400
In-reply-to: <28118.1509572045@famine>
Content-ID: <10967.1509582913.1@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh <jay.vosburgh@canonical.com> wrote:

>Alex Sidorenko <alexandre.sidorenko@hpe.com> wrote:
>
>>The problem has been found while trying to deploy RHEL7 on HPE Synergy
>>platform, it is seen both in customer's environment and in HPE test lab.
>>
>>There are several bonds configured in TLB mode and miimon=100, all other
>>options are default. Slaves are connected to VirtualConnect
>>modules. Rebooting a VC module should bring one bond slave (ens3f0) down
>>temporarily, but not another one (ens3f1). But what we see is
>>
>>Oct 24 10:37:12 SYDC1LNX kernel: bond0: link status up again after 0 ms for interface ens3f1

	In net-next, I don't see a path in the code that will lead to
this message, as it would apparently require entering
bond_miimon_inspect in state BOND_LINK_FAIL but with downdelay set to 0.
If downdelay is 0, the code will transition to BOND_LINK_DOWN and not
remain in _FAIL state.

>>and it never recovers. When VC reboot is complete, everything goes back to normal again.
>>
>>Redhat has backported all recent upstream commits and instrumented the
>>bonding driver. We have found the following (when VC goes down)
>>
>>In bond_miimon_inspect() the first slave goes to
>>	bond_propose_link_state(slave, BOND_LINK_FAIL);
>>		and
>>	slave->new_link = BOND_LINK_DOWN;
>>
>>The second slave is still
>>	slave->link = BOND_LINK_UP;
>>		and
>>        slave->new_link = BOND_LINK_NOCHANGE;
>>
>>This is as expected. But in bond_miimon_commit() we see that _both_ slaves
>>are in BOND_LINK_FAIL.  That is, something changes the state of the second
>>slave from another thread. We suspect the NetworkManager, as the problem
>>is there _only_ when bonds are controlled by it, if we set
>>NM_CONTROLLED=no everything starts working normally.
>>
>>While we still do not understand how NM affects bond state, I think that
>>bonding driver needs to be made reliable enough to recover even from this
>>state.
>
>	You're suggesting that the bonding driver be able to distinguish
>"false" down states set by network manager from a genuine link failure?
>Am I misunderstanding?
>
>>At this moment when we enter bond_miimon_inspect() with
>>slave->link = BOND_LINK_FAIL and are in the following code
>>
>>                        /*FALLTHRU*/
>>                case BOND_LINK_BACK:
>>                        if (!link_state) {
>>                                bond_propose_link_state(slave, BOND_LINK_DOWN);
>>                                netdev_info(bond->dev, "link status down
>>again after %d ms for interface %s\n",
>>                                            (bond->params.updelay - slave->delay) *
>>                                            bond->params.miimon,
>>                                            slave->dev->name);
>>
>>                                commit++;
>>                                continue;
>>                        }
>>
>
>	Looking at bonding in the current net-next, if a slave enters
>bond_miimon_inspect with slave->link == BOND_LINK_FAIL, it will not
>proceed to the BOND_LINK_BACK block of the switch; BOND_LINK_FAIL does
>not fall through that far.
>
>	Did you actually mean the BOND_LINK_FAIL block of the switch?
>I'll assume so for the rest of my reply.
>
>>we propose a new state and do 'commit++', but we do not change
>>slave->new_link from BOND_LINK_NOCHANGE. As a result, bond_miimon_commit()
>>will not process this slave.
>>
>>The following patch fixes the issue:
>>
>>****
>>If we enter bond_miimon_inspect() with slave_link=BOND_LINK_FAIL
>>and recover, we do bond_propose_link_state(slave, BOND_LINK_UP);
>>but do not change slave->new_link, so it is left in
>>BOND_LINK_NOCHANGE. As a result, bond_miimon_commit() will not
>>process that slave and it never recovers. We need to set
>>slave->new_link = BOND_LINK_UP to make bond_miimon_commit() work
>
>	What is your downdelay set to?  In principle,
>bond_miimon_inspect should not enter with a slave in BOND_LINK_FAIL
>state if downdelay is 0.
>
>> drivers/net/bonding/bond_main.c | 1 +
>> 1 file changed, 1 insertion(+)
>>
>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>index c99dc59..07aa7ba 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -2072,6 +2072,7 @@ static int bond_miimon_inspect(struct bonding *bond)
>>                                            (bond->params.downdelay - slave->delay) *
>>                                            bond->params.miimon,
>>                                            slave->dev->name);
>>+                               slave->new_link = BOND_LINK_UP;
>>                                commit++;
>>                                continue;
>>                        }
>>-- 
>>2.7.4
>
>	Your patch does not apply to net-next, so I'm not absolutely
>sure where this is, but presuming that this is in the BOND_LINK_FAIL
>case of the switch, it looks like both BOND_LINK_FAIL and BOND_LINK_BACK
>will have the issue that if the link recovers or fails, respectively,
>within the delay window (for down/updelay > 0) it won't set a
>slave->new_link.
>
>	Looks like this got lost somewhere along the line, as originally
>the transition back to UP (or DOWN) happened immediately, and that has
>been lost somewhere.
>
>	I'll have to dig out when that broke, but I'll see about a test
>patch this afternoon.

	The case I was concerned with was moved around; the proposed
state is committed in bond_mii_monitor.  But to commit to _FAIL state,
the downdelay would have to be > 0.  I'm not seeing any errors in
net-next; can you reproduce your erroneous behavior on net-next?

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
