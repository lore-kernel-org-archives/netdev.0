From: Mason <slash.tmp@free.fr>
Subject: Initializing MAC address at run-time
Date: Wed, 18 Jan 2017 15:03:57 +0100
Message-ID: <e083ed68-0e8e-380e-23bd-5ad387c88575@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
 Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>,
 Arnd Bergmann <arnd@arndb.de>, Kevin Hilman <khilman@kernel.org>
To: Linux ARM <linux-arm-kernel@lists.infradead.org>,
 DT <devicetree@vger.kernel.org>, netdev <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Language: 
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello,

When my system boots up, eth0 is given a seemingly random MAC address.

[    0.950734] nb8800 26000.ethernet eth0: MAC address ba:de:d6:38:b8:38
[    0.957334] nb8800 26000.ethernet eth0: MAC address 6e:f1:48:de:d6:c4


The DT node for eth0 is:

	eth0: ethernet@26000 {
		compatible = "sigma,smp8734-ethernet";
		reg = <0x26000 0x800>;
		interrupts = <38 IRQ_TYPE_LEVEL_HIGH>;
		clocks = <&clkgen SYS_CLK>;
	};

Documentation/devicetree/bindings/net/ethernet.txt mentions
- local-mac-address: array of 6 bytes, specifies the MAC address that was
  assigned to the network device;

And indeed, if I define this property, eth0 ends up with the MAC address
I specify in the device tree. But of course, I don't want all my boards
to share the same MAC address. Every interface has a unique MAC address.

In fact, the boot loader (not Uboot, a custom non-DT boot loader) stores
the MAC address somewhere in MMIO space, in some weird custom format.

So, at init, I can find the MAC address, and dynamically insert the
"local-mac-address" property in the eth0 node.

Is there another (better) way to do this?

I'll post my code below, for illustration purpose.

Mark suggested this can be done from user-space, but I can't do that,
because I'm using an NFS rootfs, so I need the network before I even
have a user-space. And the DHCP server is configured to serve different
root filesystems, based on the MAC address.

I need to do something similar with the NAND partitions. The boot loader
stores the partition offsets somewhere, and I need to pass this info
to the NAND framework, so I assumed that inserting the corresponding
properties at run-time was the correct way to do it.

Regards.



#include <linux/of.h>
#include <linux/io.h>
#include <asm/unaligned.h>

#define XENV_LRRW_ADDR	0x61a00
#define XENV_LRRW_SIZE	628

static u8 xenv[XENV_LRRW_SIZE] __initdata;

static void __init *xenv_lookup(void *addr, const char *key, int keylen)
{
	u32 len = le32_to_cpup(addr);
	void *end = addr + len;

	if (len > XENV_LRRW_SIZE)
		return NULL;

	for (addr += 36; addr < end; addr += len)
	{
		len = get_unaligned_be16(addr) & 0xfff;
		if (strcmp(key, addr + 2) == 0)
			return addr + 2 + keylen;
	}

	return NULL;
}

static struct property prop;
static u8 mac[6];

static const char mac_lo[] __initconst = "lrrw.maclo";
static const char mac_hi[] __initconst = "lrrw.machi";

static int __init tango_get_mac_address(void *xenv)
{
	struct device_node *np = of_find_node_by_path("eth0");
	u8 *lo = xenv_lookup(xenv, mac_lo, sizeof mac_lo);
	u8 *hi = xenv_lookup(xenv, mac_hi, sizeof mac_hi);

	if (np == NULL || lo == NULL || hi == NULL) return -ENODEV;

	mac[0] = hi[1];
	mac[1] = hi[0];
	mac[2] = lo[3];
	mac[3] = lo[2];
	mac[4] = lo[1];
	mac[5] = lo[0];

	prop.name = "local-mac-address";
	prop.length = sizeof mac;
	prop.value = mac;

	return of_update_property(np, &prop);
}

static int __init mac_fixup(void)
{
	void __iomem *xenv_orig = ioremap(XENV_LRRW_ADDR, XENV_LRRW_SIZE);
	memcpy_fromio(xenv, xenv_orig, XENV_LRRW_SIZE);
	iounmap(xenv_orig);
	return tango_get_mac_address(xenv);
}

device_initcall(mac_fixup);
