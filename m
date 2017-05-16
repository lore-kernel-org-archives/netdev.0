From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] rt2x00: improve calling conventions for register
 accessors
Date: Tue, 16 May 2017 16:23:43 +0200
Message-ID: <20170516142342.GA6086@redhat.com>
References: <20170515134711.2770374-1-arnd@arndb.de>
 <20170515142520.GA13996@redhat.com>
 <20170515.103951.2305484593464882104.davem@davemloft.net>
 <20170516115511.GA4230@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arnd@arndb.de, helmut.schaa@googlemail.com, kvalo@codeaurora.org,
        daniel@makrotopia.org, dev@kresin.me, johannes.berg@intel.com,
        pozega.tomislav@gmail.com, vasilugin@yandex.ru, roman@advem.lv,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42238 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751938AbdEPOYH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 10:24:07 -0400
Content-Disposition: inline
In-Reply-To: <20170516115511.GA4230@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 01:55:17PM +0200, Stanislaw Gruszka wrote:
> On Mon, May 15, 2017 at 10:39:51AM -0400, David Miller wrote:
> > From: Stanislaw Gruszka <sgruszka@redhat.com>
> > Date: Mon, 15 May 2017 16:28:01 +0200
> > 
> > > On Mon, May 15, 2017 at 03:46:55PM +0200, Arnd Bergmann wrote:
> > >> With CONFIG_KASAN enabled and gcc-7, we get a warning about rather high
> > >> stack usage (with a private patch set I have to turn on this warning,
> > >> which I intend to get into the next kernel release):
> > >> 
> > >> wireless/ralink/rt2x00/rt2800lib.c: In function 'rt2800_bw_filter_calibration':
> > >> wireless/ralink/rt2x00/rt2800lib.c:7990:1: error: the frame size of 2144 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
> > >> 
> > >> The problem is that KASAN inserts a redzone around each local variable that
> > >> gets passed by reference, and the newly added function has a lot of them.
> > >> We can easily avoid that here by changing the calling convention to have
> > >> the output as the return value of the function. This should also results in
> > >> smaller object code, saving around 4KB in .text with KASAN, or 2KB without
> > >> KASAN.
> > >> 
> > >> Fixes: 41977e86c984 ("rt2x00: add support for MT7620")
> > >> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > >> ---
> > >>  drivers/net/wireless/ralink/rt2x00/rt2800lib.c | 319 +++++++++++++------------
> > >>  1 file changed, 164 insertions(+), 155 deletions(-)
> > > 
> > > We have read(, &val) calling convention since forever in rt2x00 and that
> > > was never a problem. I dislike to change that now to make some tools
> > > happy, I think problem should be fixed in the tools instead.
> > 
> > Passing return values by reference is and always has been a really
> > poor way to achieve what these functions are doing.
> > 
> > And frankly, whilst the tool could see what's going on here better, we
> > should be making code easier rather than more difficult to audit.
> > 
> > I am therefore very much in favor of Arnd's change.
> > 
> > This isn't even a situation where there are multiple return values,
> > such as needing to signal an error and return an unsigned value at the
> > same time.
> > 
> > These functions return _one_ value, and therefore they should be
> > returned as a true return value.
> 
> In rt2x00 driver we use poor convention in other kind of registers
> accessors like bbp, mac, eeprom. I dislike to changing only rfcsr
> accessors and leaving others in the old way. And changing all accessors
> would be massive and error prone change, which I'm not prefer either.
> 
> Arnd, could this be fixed by refactoring rt2800_bw_filter_calibration()
> function (which is enormous and definitely should be split into smaller
> subroutines) ? If not, I would accept this patch.

Does below patch make things better with KASAN compilation ? 

diff --git a/drivers/net/wireless/ralink/rt2x00/rt2800lib.c b/drivers/net/wireless/ralink/rt2x00/rt2800lib.c
index d11c7b2..4b85ef3 100644
--- a/drivers/net/wireless/ralink/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/ralink/rt2x00/rt2800lib.c
@@ -7740,6 +7740,39 @@ static char rt2800_lp_tx_filter_bw_cal(struct rt2x00_dev *rt2x00dev)
 	return cal_val;
 }
 
+#define RF_SAVE_NUM 24
+#define BBP_SAVE_NUM 3
+static const int rf_save_ids[RF_SAVE_NUM] = {0, 1, 3, 4, 5, 6, 7, 8,
+	17, 18, 19, 20, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 58, 59};
+
+static void rt2800_phy_save(struct rt2x00_dev *rt2x00dev,
+			    u8 *const bbp_regs, u8 *const rf_regs)
+{
+	int i;
+
+	rt2800_bbp_read(rt2x00dev, 23, &bbp_regs[0]);
+
+	rt2800_bbp_dcoc_read(rt2x00dev, 0, &bbp_regs[1]);
+	rt2800_bbp_dcoc_read(rt2x00dev, 2, &bbp_regs[2]);
+
+	for (i = 0; i < RF_SAVE_NUM; i++)
+		rt2800_rfcsr_read_bank(rt2x00dev, 5, rf_save_ids[i], &rf_regs[i]);
+}
+
+static void rt2800_phy_restore(struct rt2x00_dev *rt2x00dev,
+			       const u8 *const bbp_regs, const u8 *const rf_regs)
+{
+	int i;
+
+	for (i = 0; i < RF_SAVE_NUM; i++)
+		rt2800_rfcsr_write_bank(rt2x00dev, 5, rf_save_ids[i], rf_regs[i]);
+
+	rt2800_bbp_write(rt2x00dev, 23, bbp_regs[0]);
+
+	rt2800_bbp_dcoc_write(rt2x00dev, 0, bbp_regs[1]);
+	rt2800_bbp_dcoc_write(rt2x00dev, 2, bbp_regs[2]);
+}
+
 static void rt2800_bw_filter_calibration(struct rt2x00_dev *rt2x00dev,
 					 bool btxcal)
 {
@@ -7751,52 +7784,15 @@ static void rt2800_bw_filter_calibration(struct rt2x00_dev *rt2x00dev,
 	int loop = 0, is_ht40, cnt;
 	u8 bbp_val, rf_val;
 	char cal_r32_init, cal_r32_val, cal_diff;
-	u8 saverfb5r00, saverfb5r01, saverfb5r03, saverfb5r04, saverfb5r05;
-	u8 saverfb5r06, saverfb5r07;
-	u8 saverfb5r08, saverfb5r17, saverfb5r18, saverfb5r19, saverfb5r20;
-	u8 saverfb5r37, saverfb5r38, saverfb5r39, saverfb5r40, saverfb5r41;
-	u8 saverfb5r42, saverfb5r43, saverfb5r44, saverfb5r45, saverfb5r46;
-	u8 saverfb5r58, saverfb5r59;
-	u8 savebbp159r0, savebbp159r2, savebbpr23;
 	u32 MAC_RF_CONTROL0, MAC_RF_BYPASS0;
+	u8 bbp_regs[BBP_SAVE_NUM];
+	u8 rf_regs[RF_SAVE_NUM];
 
 	/* Save MAC registers */
 	rt2800_register_read(rt2x00dev, RF_CONTROL0, &MAC_RF_CONTROL0);
 	rt2800_register_read(rt2x00dev, RF_BYPASS0, &MAC_RF_BYPASS0);
 
-	/* save BBP registers */
-	rt2800_bbp_read(rt2x00dev, 23, &savebbpr23);
-
-	rt2800_bbp_dcoc_read(rt2x00dev, 0, &savebbp159r0);
-	rt2800_bbp_dcoc_read(rt2x00dev, 2, &savebbp159r2);
-
-	/* Save RF registers */
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 0, &saverfb5r00);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 1, &saverfb5r01);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 3, &saverfb5r03);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 4, &saverfb5r04);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 5, &saverfb5r05);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 6, &saverfb5r06);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 7, &saverfb5r07);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 8, &saverfb5r08);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 17, &saverfb5r17);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 18, &saverfb5r18);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 19, &saverfb5r19);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 20, &saverfb5r20);
-
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 37, &saverfb5r37);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 38, &saverfb5r38);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 39, &saverfb5r39);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 40, &saverfb5r40);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 41, &saverfb5r41);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 42, &saverfb5r42);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 43, &saverfb5r43);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 44, &saverfb5r44);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 45, &saverfb5r45);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 46, &saverfb5r46);
-
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 58, &saverfb5r58);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 59, &saverfb5r59);
+	rt2800_phy_save(rt2x00dev, bbp_regs, rf_regs);
 
 	rt2800_rfcsr_read_bank(rt2x00dev, 5, 0, &rf_val);
 	rf_val |= 0x3;
@@ -7948,37 +7944,7 @@ static void rt2800_bw_filter_calibration(struct rt2x00_dev *rt2x00dev,
 		loop++;
 	} while (loop <= 1);
 
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 0, saverfb5r00);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 1, saverfb5r01);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 3, saverfb5r03);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 4, saverfb5r04);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 5, saverfb5r05);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 6, saverfb5r06);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 7, saverfb5r07);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 8, saverfb5r08);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 17, saverfb5r17);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 18, saverfb5r18);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 19, saverfb5r19);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 20, saverfb5r20);
-
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 37, saverfb5r37);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 38, saverfb5r38);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 39, saverfb5r39);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 40, saverfb5r40);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 41, saverfb5r41);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 42, saverfb5r42);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 43, saverfb5r43);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 44, saverfb5r44);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 45, saverfb5r45);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 46, saverfb5r46);
-
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 58, saverfb5r58);
-	rt2800_rfcsr_write_bank(rt2x00dev, 5, 59, saverfb5r59);
-
-	rt2800_bbp_write(rt2x00dev, 23, savebbpr23);
-
-	rt2800_bbp_dcoc_write(rt2x00dev, 0, savebbp159r0);
-	rt2800_bbp_dcoc_write(rt2x00dev, 2, savebbp159r2);
+	rt2800_phy_restore(rt2x00dev, bbp_regs, rf_regs);
 
 	rt2800_bbp_read(rt2x00dev, 4, &bbp_val);
 	rt2x00_set_field8(&bbp_val, BBP4_BANDWIDTH,
