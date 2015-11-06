From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net] net/qlcnic: fix mac address restore in bond mode
 5/6
Date: Fri, 06 Nov 2015 11:25:25 -0500
Message-ID: <563CD475.5090801@redhat.com>
References: <1446819931-60897-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dept-GELinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	Manish Chopra <manish.chopra@qlogic.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446819931-60897-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarod Wilson wrote:
> The bonding driver saves a copy of slaves' original mac address and then
> assigns whatever mac as needed to the slave, depending on mode. In at
> least modes 5 and 6 (balance-tlb, balance-alb), it often ends up being the
> mac address of another slave. On release from the bond, the original mac
> address is supposed to get restored via a dev_set_mac_address() call in
> the bonding driver's __bond_release_one() function, which calls the
> slave's ndo_set_mac_address function, which for qlcnic, is
> qlcnic_set_mac().

I didn't entirely flesh out this comment with some other relevant 
thoughts. The qlcnic interface getting assigned another interface's mac 
while in the bond is even more of a problem when you release the qlcnic 
interface and the interface that it was borrowing an address from, 
because now you have two interfaces in the system claiming to have the 
same mac address, which by itself can be problematic, and also causes 
problems if/when you try to add them back into a bond.


> Now, this function tries to be somewhat intelligent and exit early if
> you're trying to set the mac address to the same thing that is already
> set. The problem here is that adapter->mac_addr isn't in sync with
> netdev->dev_addr. The qlcnic driver still has the original mac stored in
> adapter->mac_addr, while the bonding driver has updated netdev->dev_addr,
> so qlcnic thinks we're trying to set the same address it already has.
>
> I think the way to go here, since the function updates both netdev and
> adapter's stored mac addresses, is to check if either of them doesn't
> match the newly requested mac. Simply checking netdev's value only could
> result in a similar mismatch and non-update, so look at both.

-- 
Jarod Wilson
jarod@redhat.com
