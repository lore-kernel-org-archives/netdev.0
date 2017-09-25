From: Yulia Kartseva <yulia.kartseva@gmail.com>
Subject: [PATCH iproute2] tc: fix ipv6 filter selector attribute for some
 prefix lengths
Date: Mon, 25 Sep 2017 11:12:38 -0700
Message-ID: <CAOgqDSEvuZVExji=NXq0s1Ze9pQTawQGy=OQxLxwU7b52xHNXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36918 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751850AbdIYSMj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 14:12:39 -0400
Received: by mail-qt0-f194.google.com with SMTP id u48so5506629qtc.4
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 11:12:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrong TCA_U32_SEL attribute packing if prefixLen AND 0x1f equals 0x1f.
These are  /31, /63, /95 and /127 prefix lengths.

Example:
# tc filter add dev eth0 protocol ipv6 parent b: prio 2307 u32 match
ip6 dst face:b00f::/31
# tc filter show dev eth0
filter parent b: protocol ipv6 pref 2307 u32
filter parent b: protocol ipv6 pref 2307 u32 fh 800: ht divisor 1
filter parent b: protocol ipv6 pref 2307 u32 fh 800::800 order 2048
key ht 800 bkt 0
  match faceb00f/ffffffff at 24


The correct match would be "faceb00e/fffffffe": don't count the last
bit of the 4th byte as the network prefix. With fix:

# tc filter show dev eth0
filter parent b: protocol ipv6 pref 2307 u32
filter parent b: protocol ipv6 pref 2307 u32 fh 800: ht divisor 1
filter parent b: protocol ipv6 pref 2307 u32 fh 800::800 order 2048
key ht 800 bkt 0
  match faceb00e/fffffffe at 24

 tc/f_u32.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index 5815be9..14b9588 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -385,8 +385,7 @@ static int parse_ip6_addr(int *argc_p, char ***argv_p,

  plen = addr.bitlen;
  for (i = 0; i < plen; i += 32) {
- /* if (((i + 31) & ~0x1F) <= plen) { */
- if (i + 31 <= plen) {
+ if (i + 31 < plen) {
  res = pack_key(sel, addr.data[i / 32],
        0xFFFFFFFF, off + 4 * (i / 32), offmask);
  if (res < 0)
