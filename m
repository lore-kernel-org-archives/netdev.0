From: David Daney <david.daney@cavium.com>
Subject: [PATCH 1/4] tools: bpf_jit_disasm:  Handle large images.
Date: Tue, 13 Jun 2017 16:49:35 -0700
Message-ID: <20170613234938.4823-2-david.daney@cavium.com>
References: <20170613234938.4823-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20170613234938.4823-1-david.daney@cavium.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Dynamically allocate memory so that JIT images larger than the size of
the statically allocated array can be handled.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 tools/net/bpf_jit_disasm.c | 37 ++++++++++++++++++++++++++-----------
 1 file changed, 26 insertions(+), 11 deletions(-)

diff --git a/tools/net/bpf_jit_disasm.c b/tools/net/bpf_jit_disasm.c
index ad572e6..422d9abd 100644
--- a/tools/net/bpf_jit_disasm.c
+++ b/tools/net/bpf_jit_disasm.c
@@ -159,8 +159,8 @@ static void put_log_buff(char *buff)
 	free(buff);
 }
 
-static unsigned int get_last_jit_image(char *haystack, size_t hlen,
-				       uint8_t *image, size_t ilen)
+static uint8_t *get_last_jit_image(char *haystack, size_t hlen,
+				   unsigned int *ilen)
 {
 	char *ptr, *pptr, *tmp;
 	off_t off = 0;
@@ -168,9 +168,10 @@ static unsigned int get_last_jit_image(char *haystack, size_t hlen,
 	regmatch_t pmatch[1];
 	unsigned long base;
 	regex_t regex;
+	uint8_t *image;
 
 	if (hlen == 0)
-		return 0;
+		return NULL;
 
 	ret = regcomp(&regex, "flen=[[:alnum:]]+ proglen=[[:digit:]]+ "
 		      "pass=[[:digit:]]+ image=[[:xdigit:]]+", REG_EXTENDED);
@@ -194,11 +195,22 @@ static unsigned int get_last_jit_image(char *haystack, size_t hlen,
 		     &flen, &proglen, &pass, &base);
 	if (ret != 4) {
 		regfree(&regex);
-		return 0;
+		return NULL;
+	}
+	if (proglen > 1000000) {
+		printf("proglen of %d too big, stopping\n", proglen);
+		return NULL;
 	}
 
+	image = malloc(proglen);
+	if (!image) {
+		printf("Out of memory\n");
+		return NULL;
+	}
+	memset(image, 0, proglen);
+
 	tmp = ptr = haystack + off;
-	while ((ptr = strtok(tmp, "\n")) != NULL && ulen < ilen) {
+	while ((ptr = strtok(tmp, "\n")) != NULL && ulen < proglen) {
 		tmp = NULL;
 		if (!strstr(ptr, "JIT code"))
 			continue;
@@ -208,10 +220,12 @@ static unsigned int get_last_jit_image(char *haystack, size_t hlen,
 		ptr = pptr;
 		do {
 			image[ulen++] = (uint8_t) strtoul(pptr, &pptr, 16);
-			if (ptr == pptr || ulen >= ilen) {
+			if (ptr == pptr) {
 				ulen--;
 				break;
 			}
+			if (ulen >= proglen)
+				break;
 			ptr = pptr;
 		} while (1);
 	}
@@ -222,7 +236,8 @@ static unsigned int get_last_jit_image(char *haystack, size_t hlen,
 	printf("%lx + <x>:\n", base);
 
 	regfree(&regex);
-	return ulen;
+	*ilen = ulen;
+	return image;
 }
 
 static void usage(void)
@@ -237,12 +252,12 @@ static void usage(void)
 int main(int argc, char **argv)
 {
 	unsigned int len, klen, opt, opcodes = 0;
-	static uint8_t image[32768];
 	char *kbuff, *file = NULL;
 	char *ofile = NULL;
 	int ofd;
 	ssize_t nr;
 	uint8_t *pos;
+	uint8_t *image = NULL;
 
 	while ((opt = getopt(argc, argv, "of:O:")) != -1) {
 		switch (opt) {
@@ -262,7 +277,6 @@ int main(int argc, char **argv)
 	}
 
 	bfd_init();
-	memset(image, 0, sizeof(image));
 
 	kbuff = get_log_buff(file, &klen);
 	if (!kbuff) {
@@ -270,8 +284,8 @@ int main(int argc, char **argv)
 		return -1;
 	}
 
-	len = get_last_jit_image(kbuff, klen, image, sizeof(image));
-	if (len <= 0) {
+	image = get_last_jit_image(kbuff, klen, &len);
+	if (!image) {
 		fprintf(stderr, "No JIT image found!\n");
 		goto done;
 	}
@@ -301,5 +315,6 @@ int main(int argc, char **argv)
 
 done:
 	put_log_buff(kbuff);
+	free(image);
 	return 0;
 }
-- 
2.9.4
