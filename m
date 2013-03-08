From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH v2] drivers/isdn: checkng length to be sure not memory overflow
Date: Fri, 08 Mar 2013 12:25:41 +0800
Message-ID: <51396845.3050600@asianux.com>
References: <512DCC4A.6060106@asianux.com> <512DD66E.4040409@suse.cz> <512DDF03.10107@asianux.com> <512DE380.8080804@suse.cz> <512EB6CA.6030609@asianux.com> <512F2AA7.4040204@suse.cz> <512F38F8.2060804@asianux.com> <512F5F14.6070801@suse.cz> <51355653.9090404@asianux.com> <5135BC3F.8070507@suse.cz> <513813F5.5040806@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Greg KH <gregkh@linuxfoundation.org>, alan@linux.intel.com,
	netdev <netdev@vger.kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:55143 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756235Ab3CHE0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 23:26:06 -0500
In-Reply-To: <513813F5.5040806@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  sizeof (cmd.parm.cmsg.para) is 50 (MAX_CAPI_PARA_LEN).
  sizeof (cmd.parm) is 80+, but less than 100.
  strlen(msg) may be more than 80+ (Modem-Commandbuffer, less than 255).
    isdn_tty_send_msg is called by isdn_tty_parse_at
    the relative parameter is m->mdmcmd (atemu *m)
    the relative command may be "+M..."

  so need check the length to be sure not memory overflow.
    cmd.parm is a union, and need keep original valid buffer length no touch


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 drivers/isdn/i4l/isdn_tty.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index d8a7d83..ebaebdf 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -902,7 +902,9 @@ isdn_tty_send_msg(modem_info *info, atemu *m, char *msg)
 	int j;
 	int l;
 
-	l = strlen(msg);
+	l = min(strlen(msg), sizeof(cmd.parm) - sizeof(cmd.parm.cmsg)
+		+ sizeof(cmd.parm.cmsg.para) - 2);
+
 	if (!l) {
 		isdn_tty_modem_result(RESULT_ERROR, info);
 		return;
-- 
1.7.7.6
