From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/3] bridge: preserve random init MAC address
Date: Tue, 18 Mar 2014 20:10:56 -0700
Message-ID: <20140318201056.7b876394@nehalam.linuxnetplumber.net>
References: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com>
	<1394680527-28970-2-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, mcgrof@suse.com,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1394680527-28970-2-git-send-email-mcgrof@do-not-panic.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Mar 2014 20:15:25 -0700
"Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:

> As it is now if you add create a bridge it gets started
> with a random MAC address and if you then add a net_device
> as a slave but later kick it out you end up with a zero
> MAC address. Instead preserve the original random MAC
> address and use it.

What is supposed to happen is that the recalculate chooses
the lowest MAC address of the slaves. If there are no slaves
it might as well just calculate a new random value. There is
not great merit in preserving the original defunct address.

Or something like this that just keeps the old value.
The bridge is in a meaningless state when there are no ports,
and when the first port is added back it will be used as the
new bridge id.

--- a/net/bridge/br_stp_if.c	2014-02-12 08:21:56.733857356 -0800
+++ b/net/bridge/br_stp_if.c	2014-03-18 20:09:09.334388826 -0700
@@ -235,6 +235,9 @@ bool br_stp_recalculate_bridge_id(struct
 			addr = p->dev->dev_addr;
 
 	}
+
+	if (addr == br_mac_zero)
+		return false;  /* keep original address */
 
 	if (ether_addr_equal(br->bridge_id.addr, addr))
 		return false;	/* no change */
