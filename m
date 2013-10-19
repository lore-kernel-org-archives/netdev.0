From: Leigh Brown <leigh@solinno.co.uk>
Subject: [PATCH RFC 0/4] MDIO bus timeout issues on Dreamplug
Date: Sat, 19 Oct 2013 17:23:50 +0100
Message-ID: <cover.1382199042.git.leigh@solinno.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 netdev@vger.kernel.org, Leigh Brown <leigh@solinno.co.uk>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

I just upgraded my Dreamplug to kernel 3.12-rc4 and began encountering
timeout errors in the log, like the following :-

orion-mdio f1072004.mdio-bus: Timeout when reading PHY

I discovered that the mv643xx_eth driver had been converted to use the
mvmdio driver to talk to the PHY rather than the old code that was
embedded in the driver.  The new code had some inconsistent timeouts
and always polled for a response rather than using the interrupt, where
available.  The timeout was 1ms when polling but the Dreamplug can
take up to 4.9ms to respond.

So, making reference to the old 3.9 driver I changed the mvmdio driver
to have more consistent timeouts and use interrupts to poll, where
available. I set the timeout to 10ms.  Patches 1 and 2 do this.

I got carried away checking the size of the code and patch 3 is a 
simple optimisation to reduce the code size. The final patch updates
the documentation in mvmdio to make it reflect the current situation.

I have tested the patches on my Dreamplug and Mirabox and have not 
encountered any issues.

One final thing I noticed when testing: you can unload the mvmdio 
driver and the machine will crash shortly after.  I tried to understand
how the module reference counting would apply to these kinds of drivers
and got a bit stuck.  I think these modules should not be unloadable
while there is an ethernet driver that uses them.

Regards,

Leigh.

Leigh Brown (4):
  net: mvmdio: make orion_mdio_wait_ready consistent
  net: mvmdio: orion_mdio_ready: remove manual poll
  net: mvmdio: slight optimisation of orion_mdio_write
  net: mvmdio: doc: mvmdio now used by mv643xx_eth

 drivers/net/ethernet/marvell/mvmdio.c |   93 +++++++++++++++------------------
 1 file changed, 42 insertions(+), 51 deletions(-)

-- 
1.7.10.4
