From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] 6pack,mkiss: fix lock inconsistency
Date: Fri, 1 Jul 2011 23:28:46 +0200
Message-ID: <201107012328.46256.arnd@arndb.de>
References: <4B2CD772.1030106@upmc.fr> <20110625163942.GB20976@linux-mips.org> <4E0DC4F3.6010203@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams@vger.kernel.org
To: Bernard F6BVP <f6bvp@free.fr>, David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4E0DC4F3.6010203@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lockdep found a locking inconsistency in the mkiss_close function:

> kernel: [ INFO: inconsistent lock state ]
> kernel: 2.6.39.1 #3
> kernel: ---------------------------------
> kernel: inconsistent {IN-SOFTIRQ-R} -> {SOFTIRQ-ON-W} usage.
> kernel: ax25ipd/2813 [HC0[0]:SC0[0]:HE1:SE1] takes:
> kernel: (disc_data_lock){+++?.-}, at: [<ffffffffa018552b>] mkiss_close+0x1b/0x90 [mkiss]
> kernel: {IN-SOFTIRQ-R} state was registered at:

The message hints that disc_data_lock is aquired with softirqs disabled,
but does not itself disable softirqs, which can in rare circumstances
lead to a deadlock. 
The same problem is present in the 6pack driver, this patch fixes both
by using write_lock_bh instead of write_lock.

Reported-by: Bernard F6BVP <f6bvp@free.fr>
Tested-by: Bernard F6BVP <f6bvp@free.fr>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Ralf Baechle<ralf@linux-mips.org>
Cc: stable@kernel.org
---
On Friday 01 July 2011 15:00:35 Bernard F6BVP wrote:
> 
> Now, who is going to commit this mkiss patch and the equivalent one for 
> sixpack.c ?

Here's a formal patch with all the right tags, I assume that David Miller
will apply that to the netdev tree.

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 9624cbf..fea7cb4 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -694,10 +694,10 @@ static void sixpack_close(struct tty_struct *tty)
 {
 	struct sixpack *sp;
 
-	write_lock(&disc_data_lock);
+	write_lock_bh(&disc_data_lock);
 	sp = tty->disc_data;
 	tty->disc_data = NULL;
-	write_unlock(&disc_data_lock);
+	write_unlock_bh(&disc_data_lock);
 	if (!sp)
 		return;
 
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index 9f84c83..324f7bf 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -813,10 +813,10 @@ static void mkiss_close(struct tty_struct *tty)
 {
 	struct mkiss *ax;
 
-	write_lock(&disc_data_lock);
+	write_lock_bh(&disc_data_lock);
 	ax = tty->disc_data;
 	tty->disc_data = NULL;
-	write_unlock(&disc_data_lock);
+	write_unlock_bh(&disc_data_lock);
 
 	if (!ax)
 		return;
