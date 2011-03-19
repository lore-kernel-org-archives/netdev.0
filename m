From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH] ROSE: prevent heap corruption with bad facilities
Date: Sat, 19 Mar 2011 19:28:33 -0400
Message-ID: <1300577313.12507.17.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org
To: ralf@linux-mips.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:51319 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098Ab1CSXfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 19:35:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When parsing the FAC_NATIONAL_DIGIS facilities field, keeping the
counter field in an unsigned char is insufficient, since the counter is
incremented by AX25_ADDR_LEN (7) with each loop.  Providing a field
length of 0xf, for example, causes heap corruption because the counter
wraps without ever reaching the length and data is copied past the
boundaries of the source_digis or dest_digis facilities arrays.  Change
the counter to an unsigned ints to prevent this wrapping and overflow.

Additionally, when parsing the FAC_CCITT_DEST_NSAP and
FAC_CCITT_SRC_NSAP facilities fields, a length of less than 10 results
in an underflow in a memcpy size, resulting in a kernel panic due to
massive heap corruption.  Abort facilities parsing on this invalid
length value.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: stable@kernel.org
---
 net/rose/rose_subr.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/net/rose/rose_subr.c b/net/rose/rose_subr.c
index 1734abb..fee9de4 100644
--- a/net/rose/rose_subr.c
+++ b/net/rose/rose_subr.c
@@ -240,7 +240,8 @@ int rose_decode(struct sk_buff *skb, int *ns, int *nr, int *q, int *d, int *m)
 static int rose_parse_national(unsigned char *p, struct rose_facilities_struct *facilities, int len)
 {
 	unsigned char *pt;
-	unsigned char l, lg, n = 0;
+	unsigned char l, n = 0;
+	unsigned int lg;
 	int fac_national_digis_received = 0;
 
 	do {
@@ -334,12 +335,16 @@ static int rose_parse_ccitt(unsigned char *p, struct rose_facilities_struct *fac
 		case 0xC0:
 			l = p[1];
 			if (*p == FAC_CCITT_DEST_NSAP) {
+				if (l < 10)
+					return -1;
 				memcpy(&facilities->source_addr, p + 7, ROSE_ADDR_LEN);
 				memcpy(callsign, p + 12,   l - 10);
 				callsign[l - 10] = '\0';
 				asc2ax(&facilities->source_call, callsign);
 			}
 			if (*p == FAC_CCITT_SRC_NSAP) {
+				if (l < 10)
+					return -1;
 				memcpy(&facilities->dest_addr, p + 7, ROSE_ADDR_LEN);
 				memcpy(callsign, p + 12, l - 10);
 				callsign[l - 10] = '\0';
@@ -379,6 +384,11 @@ int rose_parse_facilities(unsigned char *p,
 
 			case FAC_CCITT:		/* CCITT */
 				len = rose_parse_ccitt(p + 1, facilities, facilities_len - 1);
+
+				/* Invalid facilities */
+				if (len < 0)
+					return 0;
+
 				facilities_len -= len + 1;
 				p += len + 1;
 				break;


