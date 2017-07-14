From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 20/22] sound: pci: avoid string overflow
	warnings
Date: Fri, 14 Jul 2017 14:07:12 +0200
Message-ID: <20170714120720.906842-21-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org,
 "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
 linux-scsi@vger.kernel.org, "Martin K . Petersen" <martin.petersen@oracle.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org,
 Takashi Sakamoto <o-takashi@sakamocchi.jp>,
 Geliang Tang <geliangtang@gmail.com>, Arnd Bergmann <arnd@arndb.de>,
 netdev@vger.kernel.org, akpm@linux-foundation.org,
 Linus Torvalds <torvalds@linux-foundation.org>,
 "David S . Miller" <davem@davemloft.net>, Guenter Roeck <linux@roeck-us.net>
To: linux-kernel@vger.kernel.org, Jaroslav Kysela <perex@perex.cz>,
 Takashi Iwai <tiwai@suse.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

With gcc-7, we get various warnings about a possible string overflow:

sound/pci/rme9652/hdspm.c: In function 'snd_hdspm_create_alsa_devices':
sound/pci/rme9652/hdspm.c:2123:17: error: ' MIDIoverMADI' directive writing 13 bytes into a region of size between 1 and 32 [-Werror=format-overflow=]
sound/pci/pcxhr/pcxhr.c: In function 'pcxhr_probe':
sound/pci/pcxhr/pcxhr.c:1647:28: error: ' [PCM #' directive writing 7 bytes into a region of size between 1 and 32 [-Werror=format-overflow=]
sound/pci/mixart/mixart.c: In function 'snd_mixart_probe':
sound/pci/mixart/mixart.c:1353:28: error: ' [PCM #' directive writing 7 bytes into a region of size between 1 and 32 [-Werror=format-overflow=]
   sprintf(card->shortname, "%s [PCM #%d]", mgr->shortname, i);
                            ^~~~~~~~~~~~~~
sound/pci/mixart/mixart.c:1353:28: note: using the range [-2147483648, 2147483647] for directive argument
sound/pci/mixart/mixart.c:1353:3: note: 'sprintf' output between 10 and 51 bytes into a destination of size 32
   sprintf(card->shortname, "%s [PCM #%d]", mgr->shortname, i);
   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sound/pci/mixart/mixart.c:1354:27: error: ' [PCM #' directive writing 7 bytes into a region of size between 1 and 80 [-Werror=format-overflow=]
   sprintf(card->longname, "%s [PCM #%d]", mgr->longname, i);
                           ^~~~~~~~~~~~~~
sound/pci/mixart/mixart.c:1354:27: note: using the range [-2147483648, 2147483647] for directive argument
sound/pci/mixart/mixart.c:1354:3: note: 'sprintf' output between 10 and 99 bytes into a destination of size 80

I have checked these all and found that the driver-private
shortname strings for mixart and pcxhr are longer than necessary,
and making them shorter will be safe while also making it clear
that no overflow can happen when they get passed as a substring
into the card shortname.

For hdspm, we have a local buffer of the same size as its substring.
In this case, making the buffer a little longer is safe as the
functions that take it as an argument all use length checking and
the strings we pass into it are actually short enough.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 sound/pci/mixart/mixart.h | 4 ++--
 sound/pci/pcxhr/pcxhr.h   | 4 ++--
 sound/pci/rme9652/hdspm.c | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/sound/pci/mixart/mixart.h b/sound/pci/mixart/mixart.h
index 426743871540..c8309e327663 100644
--- a/sound/pci/mixart/mixart.h
+++ b/sound/pci/mixart/mixart.h
@@ -75,8 +75,8 @@ struct mixart_mgr {
 	struct mem_area mem[2];
 
 	/* share the name */
-	char shortname[32];         /* short name of this soundcard */
-	char longname[80];          /* name of this soundcard */
+	char shortname[16];         /* short name of this soundcard */
+	char longname[40];          /* name of this soundcard */
 
 	/* one and only blocking message or notification may be pending  */
 	u32 pending_event;
diff --git a/sound/pci/pcxhr/pcxhr.h b/sound/pci/pcxhr/pcxhr.h
index 9e39e509a3ef..4909a43ce3d9 100644
--- a/sound/pci/pcxhr/pcxhr.h
+++ b/sound/pci/pcxhr/pcxhr.h
@@ -75,8 +75,8 @@ struct pcxhr_mgr {
 	unsigned long port[3];
 
 	/* share the name */
-	char shortname[32];		/* short name of this soundcard */
-	char longname[96];		/* name of this soundcard */
+	char shortname[16];		/* short name of this soundcard */
+	char longname[40];		/* name of this soundcard */
 
 	struct pcxhr_rmh *prmh;
 
diff --git a/sound/pci/rme9652/hdspm.c b/sound/pci/rme9652/hdspm.c
index 254c3d040118..a1cbf5938a0e 100644
--- a/sound/pci/rme9652/hdspm.c
+++ b/sound/pci/rme9652/hdspm.c
@@ -2061,7 +2061,7 @@ static int snd_hdspm_create_midi(struct snd_card *card,
 				 struct hdspm *hdspm, int id)
 {
 	int err;
-	char buf[32];
+	char buf[64];
 
 	hdspm->midi[id].id = id;
 	hdspm->midi[id].hdspm = hdspm;
-- 
2.9.0
