From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH iproute2-3.8 1/6] iproute2: Don't propogate mounts out of ip
Date: Thu, 17 Jan 2013 16:45:33 -0800
Message-ID: <87y5fr48uq.fsf_-_@xmission.com>
References: <87a9u4q7k9.fsf@xmission.com>
	<1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
	<87622v5ngt.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Petr =?utf-8?Q?=C5=A0abata?= <contyk@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53508 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076Ab3ARApq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 19:45:46 -0500
In-Reply-To: <87622v5ngt.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Thu, 17 Jan 2013 16:44:34 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Some systems are now following the advice in
linux/Documentation/sharedsubtrees.txt and running with all mount
points shared between all mount namespaces by default.

After creating the mount namespace call mount on / with
MS_SLAVE|MS_REC to modify all mounts in the new mount namespace to
slave mounts if they are shared or private mounts otherwise.
Guarnateeing that changes to the mount namespace created with
"ip netns exec" don't propgate to other namespaces.

Reported-by: Petr =C5=A0abata <contyk@redhat.com>
Tested-by: Petr =C5=A0abata <contyk@redhat.com>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 ip/ipnetns.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index e41a598..f2c42ba 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -152,6 +152,12 @@ static int netns_exec(int argc, char **argv)
 		fprintf(stderr, "unshare failed: %s\n", strerror(errno));
 		return -1;
 	}
+	/* Don't let any mounts propogate back to the parent */
+	if (mount("", "/", "none", MS_SLAVE | MS_REC, NULL)) {
+		fprintf(stderr, "mount --make-rslave / failed: %s\n",
+			strerror(errno));
+		return -1;
+	}
 	/* Mount a version of /sys that describes the network namespace */
 	if (umount2("/sys", MNT_DETACH) < 0) {
 		fprintf(stderr, "umount of /sys failed: %s\n", strerror(errno));
--=20
1.7.5.4
