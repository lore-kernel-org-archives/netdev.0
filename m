From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH 0/3] drivers: expand usage of request_firmware_direct()
Date: Tue, 24 Jun 2014 15:39:40 -0700
Message-ID: <1403649583-12707-1-git-send-email-mcgrof@do-not-panic.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, "Luis R. Rodriguez" <mcgrof@suse.com>
To: tiwai@suse.de, chunkeey@googlemail.com, leedom@chelsio.com,
	cocci@systeme.lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

Takashi added request_firmware_direct() via bba3a87e9 through v3.14-rc1
which avoids the unnecessary delay introduced by using the udev firmware
loader in case the first try failed when loading we know loading "firmware"
is optional. The first use case was for microcode update but if drivers are
using it for optional configuration updates, custom EEPROMs, and other
junk other than firmware that should apply as well as good use cases,
specially if the driver already had a first phase in which it loaded
the first required firmware. While reviewing one driver I figured it'd
be best to try to give formalizing a check with SmPL. This isn't perfect
it had 1 false possitive drivers/fmc/fmc-fakedev.c on the entire kernel
run but my hope is this can be extended a bit more to build more
confidence, and then perhaps stuff it as a coccicheck.

I suppose this will not be required once and if we remove
CONFIG_FW_LOADER_USER_HELPER. Is that ever going away for good? I know
there was a recent attempt to remove the udev loader support but
it was unclear if the special alternative helper support would be
removed upstream from the kernel.

@ firmware_not_critical @
expression cf;
expression config_file;
expression dev;
int ret;
identifier l;
statement S;
@@

-	ret = request_firmware(&cf, config_file, dev);
+	ret = request_firmware_direct(&cf, config_file, dev);
	if (ret < 0) {
		... when != goto l;
		    when != return ret;
		    when any
	} else {
		...
		release_firmware(cf);
		...
	}


Luis R. Rodriguez (3):
  mmc: vub300: use request_firmware_direct() for pseudo code
  cxgb4: make configuration load use request_firmware_direct()
  p54: use request_firmware_direct() for optional EEPROM override

 drivers/mmc/host/vub300.c                       | 5 +++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 2 +-
 drivers/net/wireless/p54/p54spi.c               | 2 +-
 3 files changed, 5 insertions(+), 4 deletions(-)

-- 
2.0.0
