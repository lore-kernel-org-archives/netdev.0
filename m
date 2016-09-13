From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v2 5/6] selftests: move ia64 tests from Documentation/ia64
Date: Tue, 13 Sep 2016 14:18:44 -0600
Message-ID: <27dc09c0d9a9fb0f372c70696732867ff8837e64.1473795601.git.shuahkh@osg.samsung.com>
References: <cover.1473795601.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-watchdog@vger.kernel.org, linux-kselftest@vger.kernel.org
To: corbet@lwn.net, richardcochran@gmail.com, wim@iguana.be,
        linux@roeck-us.net, nab@linux-iscsi.org,
        maheshkhanwalkar@gmail.com, timur@codeaurora.org, arnd@arndb.de,
        ghackmann@google.com, ben@decadent.org.uk, thuth@redhat.com,
        christopher.s.hall@intel.com, john.stultz@linaro.org,
        sergei.shtylyov@cogentembedded.com, mpe@ellerman.id.au,
        jani.nikula@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1473795601.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1473795601.git.shuahkh@osg.samsung.com>
References: <cover.1473795601.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove ia64 from Makefile to move the test to selftests.

Update ia64 Makefile to work under selftests. ia64 will not be run as part
of selftests suite and will not be included in install targets. They can be
built separately for now.

The original Makefile built this test on all archirectures and this update
doesn't change that.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 Documentation/Makefile                       |   2 +-
 Documentation/ia64/.gitignore                |   1 -
 Documentation/ia64/Makefile                  |   5 -
 Documentation/ia64/aliasing-test.c           | 263 ---------------------------
 tools/testing/selftests/ia64/.gitignore      |   1 +
 tools/testing/selftests/ia64/Makefile        |   8 +
 tools/testing/selftests/ia64/aliasing-test.c | 263 +++++++++++++++++++++++++++
 7 files changed, 273 insertions(+), 270 deletions(-)
 delete mode 100644 Documentation/ia64/.gitignore
 delete mode 100644 Documentation/ia64/Makefile
 delete mode 100644 Documentation/ia64/aliasing-test.c
 create mode 100644 tools/testing/selftests/ia64/.gitignore
 create mode 100644 tools/testing/selftests/ia64/Makefile
 create mode 100644 tools/testing/selftests/ia64/aliasing-test.c

diff --git a/Documentation/Makefile b/Documentation/Makefile
index 085b917..572e9b7 100644
--- a/Documentation/Makefile
+++ b/Documentation/Makefile
@@ -1,3 +1,3 @@
 subdir-y := accounting auxdisplay blackfin \
-	ia64 laptops mic misc-devices \
+	laptops mic misc-devices \
 	networking pcmcia timers watchdog
diff --git a/Documentation/ia64/.gitignore b/Documentation/ia64/.gitignore
deleted file mode 100644
index ab806ed..0000000
--- a/Documentation/ia64/.gitignore
+++ /dev/null
@@ -1 +0,0 @@
-aliasing-test
diff --git a/Documentation/ia64/Makefile b/Documentation/ia64/Makefile
deleted file mode 100644
index d493163..0000000
--- a/Documentation/ia64/Makefile
+++ /dev/null
@@ -1,5 +0,0 @@
-# List of programs to build
-hostprogs-y := aliasing-test
-
-# Tell kbuild to always build the programs
-always := $(hostprogs-y)
diff --git a/Documentation/ia64/aliasing-test.c b/Documentation/ia64/aliasing-test.c
deleted file mode 100644
index 62a190d..0000000
--- a/Documentation/ia64/aliasing-test.c
+++ /dev/null
@@ -1,263 +0,0 @@
-/*
- * Exercise /dev/mem mmap cases that have been troublesome in the past
- *
- * (c) Copyright 2007 Hewlett-Packard Development Company, L.P.
- *	Bjorn Helgaas <bjorn.helgaas@hp.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <stdlib.h>
-#include <stdio.h>
-#include <sys/types.h>
-#include <dirent.h>
-#include <fcntl.h>
-#include <fnmatch.h>
-#include <string.h>
-#include <sys/ioctl.h>
-#include <sys/mman.h>
-#include <sys/stat.h>
-#include <unistd.h>
-#include <linux/pci.h>
-
-int sum;
-
-static int map_mem(char *path, off_t offset, size_t length, int touch)
-{
-	int fd, rc;
-	void *addr;
-	int *c;
-
-	fd = open(path, O_RDWR);
-	if (fd == -1) {
-		perror(path);
-		return -1;
-	}
-
-	if (fnmatch("/proc/bus/pci/*", path, 0) == 0) {
-		rc = ioctl(fd, PCIIOC_MMAP_IS_MEM);
-		if (rc == -1)
-			perror("PCIIOC_MMAP_IS_MEM ioctl");
-	}
-
-	addr = mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, offset);
-	if (addr == MAP_FAILED)
-		return 1;
-
-	if (touch) {
-		c = (int *) addr;
-		while (c < (int *) (addr + length))
-			sum += *c++;
-	}
-
-	rc = munmap(addr, length);
-	if (rc == -1) {
-		perror("munmap");
-		return -1;
-	}
-
-	close(fd);
-	return 0;
-}
-
-static int scan_tree(char *path, char *file, off_t offset, size_t length, int touch)
-{
-	struct dirent **namelist;
-	char *name, *path2;
-	int i, n, r, rc = 0, result = 0;
-	struct stat buf;
-
-	n = scandir(path, &namelist, 0, alphasort);
-	if (n < 0) {
-		perror("scandir");
-		return -1;
-	}
-
-	for (i = 0; i < n; i++) {
-		name = namelist[i]->d_name;
-
-		if (fnmatch(".", name, 0) == 0)
-			goto skip;
-		if (fnmatch("..", name, 0) == 0)
-			goto skip;
-
-		path2 = malloc(strlen(path) + strlen(name) + 3);
-		strcpy(path2, path);
-		strcat(path2, "/");
-		strcat(path2, name);
-
-		if (fnmatch(file, name, 0) == 0) {
-			rc = map_mem(path2, offset, length, touch);
-			if (rc == 0)
-				fprintf(stderr, "PASS: %s 0x%lx-0x%lx is %s\n", path2, offset, offset + length, touch ? "readable" : "mappable");
-			else if (rc > 0)
-				fprintf(stderr, "PASS: %s 0x%lx-0x%lx not mappable\n", path2, offset, offset + length);
-			else {
-				fprintf(stderr, "FAIL: %s 0x%lx-0x%lx not accessible\n", path2, offset, offset + length);
-				return rc;
-			}
-		} else {
-			r = lstat(path2, &buf);
-			if (r == 0 && S_ISDIR(buf.st_mode)) {
-				rc = scan_tree(path2, file, offset, length, touch);
-				if (rc < 0)
-					return rc;
-			}
-		}
-
-		result |= rc;
-		free(path2);
-
-skip:
-		free(namelist[i]);
-	}
-	free(namelist);
-	return result;
-}
-
-char buf[1024];
-
-static int read_rom(char *path)
-{
-	int fd, rc;
-	size_t size = 0;
-
-	fd = open(path, O_RDWR);
-	if (fd == -1) {
-		perror(path);
-		return -1;
-	}
-
-	rc = write(fd, "1", 2);
-	if (rc <= 0) {
-		close(fd);
-		perror("write");
-		return -1;
-	}
-
-	do {
-		rc = read(fd, buf, sizeof(buf));
-		if (rc > 0)
-			size += rc;
-	} while (rc > 0);
-
-	close(fd);
-	return size;
-}
-
-static int scan_rom(char *path, char *file)
-{
-	struct dirent **namelist;
-	char *name, *path2;
-	int i, n, r, rc = 0, result = 0;
-	struct stat buf;
-
-	n = scandir(path, &namelist, 0, alphasort);
-	if (n < 0) {
-		perror("scandir");
-		return -1;
-	}
-
-	for (i = 0; i < n; i++) {
-		name = namelist[i]->d_name;
-
-		if (fnmatch(".", name, 0) == 0)
-			goto skip;
-		if (fnmatch("..", name, 0) == 0)
-			goto skip;
-
-		path2 = malloc(strlen(path) + strlen(name) + 3);
-		strcpy(path2, path);
-		strcat(path2, "/");
-		strcat(path2, name);
-
-		if (fnmatch(file, name, 0) == 0) {
-			rc = read_rom(path2);
-
-			/*
-			 * It's OK if the ROM is unreadable.  Maybe there
-			 * is no ROM, or some other error occurred.  The
-			 * important thing is that no MCA happened.
-			 */
-			if (rc > 0)
-				fprintf(stderr, "PASS: %s read %d bytes\n", path2, rc);
-			else {
-				fprintf(stderr, "PASS: %s not readable\n", path2);
-				return rc;
-			}
-		} else {
-			r = lstat(path2, &buf);
-			if (r == 0 && S_ISDIR(buf.st_mode)) {
-				rc = scan_rom(path2, file);
-				if (rc < 0)
-					return rc;
-			}
-		}
-
-		result |= rc;
-		free(path2);
-
-skip:
-		free(namelist[i]);
-	}
-	free(namelist);
-	return result;
-}
-
-int main(void)
-{
-	int rc;
-
-	if (map_mem("/dev/mem", 0, 0xA0000, 1) == 0)
-		fprintf(stderr, "PASS: /dev/mem 0x0-0xa0000 is readable\n");
-	else
-		fprintf(stderr, "FAIL: /dev/mem 0x0-0xa0000 not accessible\n");
-
-	/*
-	 * It's not safe to blindly read the VGA frame buffer.  If you know
-	 * how to poke the card the right way, it should respond, but it's
-	 * not safe in general.  Many machines, e.g., Intel chipsets, cover
-	 * up a non-responding card by just returning -1, but others will
-	 * report the failure as a machine check.
-	 */
-	if (map_mem("/dev/mem", 0xA0000, 0x20000, 0) == 0)
-		fprintf(stderr, "PASS: /dev/mem 0xa0000-0xc0000 is mappable\n");
-	else
-		fprintf(stderr, "FAIL: /dev/mem 0xa0000-0xc0000 not accessible\n");
-
-	if (map_mem("/dev/mem", 0xC0000, 0x40000, 1) == 0)
-		fprintf(stderr, "PASS: /dev/mem 0xc0000-0x100000 is readable\n");
-	else
-		fprintf(stderr, "FAIL: /dev/mem 0xc0000-0x100000 not accessible\n");
-
-	/*
-	 * Often you can map all the individual pieces above (0-0xA0000,
-	 * 0xA0000-0xC0000, and 0xC0000-0x100000), but can't map the whole
-	 * thing at once.  This is because the individual pieces use different
-	 * attributes, and there's no single attribute supported over the
-	 * whole region.
-	 */
-	rc = map_mem("/dev/mem", 0, 1024*1024, 0);
-	if (rc == 0)
-		fprintf(stderr, "PASS: /dev/mem 0x0-0x100000 is mappable\n");
-	else if (rc > 0)
-		fprintf(stderr, "PASS: /dev/mem 0x0-0x100000 not mappable\n");
-	else
-		fprintf(stderr, "FAIL: /dev/mem 0x0-0x100000 not accessible\n");
-
-	scan_tree("/sys/class/pci_bus", "legacy_mem", 0, 0xA0000, 1);
-	scan_tree("/sys/class/pci_bus", "legacy_mem", 0xA0000, 0x20000, 0);
-	scan_tree("/sys/class/pci_bus", "legacy_mem", 0xC0000, 0x40000, 1);
-	scan_tree("/sys/class/pci_bus", "legacy_mem", 0, 1024*1024, 0);
-
-	scan_rom("/sys/devices", "rom");
-
-	scan_tree("/proc/bus/pci", "??.?", 0, 0xA0000, 1);
-	scan_tree("/proc/bus/pci", "??.?", 0xA0000, 0x20000, 0);
-	scan_tree("/proc/bus/pci", "??.?", 0xC0000, 0x40000, 1);
-	scan_tree("/proc/bus/pci", "??.?", 0, 1024*1024, 0);
-
-	return rc;
-}
diff --git a/tools/testing/selftests/ia64/.gitignore b/tools/testing/selftests/ia64/.gitignore
new file mode 100644
index 0000000..ab806ed
--- /dev/null
+++ b/tools/testing/selftests/ia64/.gitignore
@@ -0,0 +1 @@
+aliasing-test
diff --git a/tools/testing/selftests/ia64/Makefile b/tools/testing/selftests/ia64/Makefile
new file mode 100644
index 0000000..2b3de2d
--- /dev/null
+++ b/tools/testing/selftests/ia64/Makefile
@@ -0,0 +1,8 @@
+TEST_PROGS := aliasing-test
+
+all: $(TEST_PROGS)
+
+include ../lib.mk
+
+clean:
+	rm -fr $(TEST_PROGS)
diff --git a/tools/testing/selftests/ia64/aliasing-test.c b/tools/testing/selftests/ia64/aliasing-test.c
new file mode 100644
index 0000000..62a190d
--- /dev/null
+++ b/tools/testing/selftests/ia64/aliasing-test.c
@@ -0,0 +1,263 @@
+/*
+ * Exercise /dev/mem mmap cases that have been troublesome in the past
+ *
+ * (c) Copyright 2007 Hewlett-Packard Development Company, L.P.
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <stdlib.h>
+#include <stdio.h>
+#include <sys/types.h>
+#include <dirent.h>
+#include <fcntl.h>
+#include <fnmatch.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <sys/mman.h>
+#include <sys/stat.h>
+#include <unistd.h>
+#include <linux/pci.h>
+
+int sum;
+
+static int map_mem(char *path, off_t offset, size_t length, int touch)
+{
+	int fd, rc;
+	void *addr;
+	int *c;
+
+	fd = open(path, O_RDWR);
+	if (fd == -1) {
+		perror(path);
+		return -1;
+	}
+
+	if (fnmatch("/proc/bus/pci/*", path, 0) == 0) {
+		rc = ioctl(fd, PCIIOC_MMAP_IS_MEM);
+		if (rc == -1)
+			perror("PCIIOC_MMAP_IS_MEM ioctl");
+	}
+
+	addr = mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, offset);
+	if (addr == MAP_FAILED)
+		return 1;
+
+	if (touch) {
+		c = (int *) addr;
+		while (c < (int *) (addr + length))
+			sum += *c++;
+	}
+
+	rc = munmap(addr, length);
+	if (rc == -1) {
+		perror("munmap");
+		return -1;
+	}
+
+	close(fd);
+	return 0;
+}
+
+static int scan_tree(char *path, char *file, off_t offset, size_t length, int touch)
+{
+	struct dirent **namelist;
+	char *name, *path2;
+	int i, n, r, rc = 0, result = 0;
+	struct stat buf;
+
+	n = scandir(path, &namelist, 0, alphasort);
+	if (n < 0) {
+		perror("scandir");
+		return -1;
+	}
+
+	for (i = 0; i < n; i++) {
+		name = namelist[i]->d_name;
+
+		if (fnmatch(".", name, 0) == 0)
+			goto skip;
+		if (fnmatch("..", name, 0) == 0)
+			goto skip;
+
+		path2 = malloc(strlen(path) + strlen(name) + 3);
+		strcpy(path2, path);
+		strcat(path2, "/");
+		strcat(path2, name);
+
+		if (fnmatch(file, name, 0) == 0) {
+			rc = map_mem(path2, offset, length, touch);
+			if (rc == 0)
+				fprintf(stderr, "PASS: %s 0x%lx-0x%lx is %s\n", path2, offset, offset + length, touch ? "readable" : "mappable");
+			else if (rc > 0)
+				fprintf(stderr, "PASS: %s 0x%lx-0x%lx not mappable\n", path2, offset, offset + length);
+			else {
+				fprintf(stderr, "FAIL: %s 0x%lx-0x%lx not accessible\n", path2, offset, offset + length);
+				return rc;
+			}
+		} else {
+			r = lstat(path2, &buf);
+			if (r == 0 && S_ISDIR(buf.st_mode)) {
+				rc = scan_tree(path2, file, offset, length, touch);
+				if (rc < 0)
+					return rc;
+			}
+		}
+
+		result |= rc;
+		free(path2);
+
+skip:
+		free(namelist[i]);
+	}
+	free(namelist);
+	return result;
+}
+
+char buf[1024];
+
+static int read_rom(char *path)
+{
+	int fd, rc;
+	size_t size = 0;
+
+	fd = open(path, O_RDWR);
+	if (fd == -1) {
+		perror(path);
+		return -1;
+	}
+
+	rc = write(fd, "1", 2);
+	if (rc <= 0) {
+		close(fd);
+		perror("write");
+		return -1;
+	}
+
+	do {
+		rc = read(fd, buf, sizeof(buf));
+		if (rc > 0)
+			size += rc;
+	} while (rc > 0);
+
+	close(fd);
+	return size;
+}
+
+static int scan_rom(char *path, char *file)
+{
+	struct dirent **namelist;
+	char *name, *path2;
+	int i, n, r, rc = 0, result = 0;
+	struct stat buf;
+
+	n = scandir(path, &namelist, 0, alphasort);
+	if (n < 0) {
+		perror("scandir");
+		return -1;
+	}
+
+	for (i = 0; i < n; i++) {
+		name = namelist[i]->d_name;
+
+		if (fnmatch(".", name, 0) == 0)
+			goto skip;
+		if (fnmatch("..", name, 0) == 0)
+			goto skip;
+
+		path2 = malloc(strlen(path) + strlen(name) + 3);
+		strcpy(path2, path);
+		strcat(path2, "/");
+		strcat(path2, name);
+
+		if (fnmatch(file, name, 0) == 0) {
+			rc = read_rom(path2);
+
+			/*
+			 * It's OK if the ROM is unreadable.  Maybe there
+			 * is no ROM, or some other error occurred.  The
+			 * important thing is that no MCA happened.
+			 */
+			if (rc > 0)
+				fprintf(stderr, "PASS: %s read %d bytes\n", path2, rc);
+			else {
+				fprintf(stderr, "PASS: %s not readable\n", path2);
+				return rc;
+			}
+		} else {
+			r = lstat(path2, &buf);
+			if (r == 0 && S_ISDIR(buf.st_mode)) {
+				rc = scan_rom(path2, file);
+				if (rc < 0)
+					return rc;
+			}
+		}
+
+		result |= rc;
+		free(path2);
+
+skip:
+		free(namelist[i]);
+	}
+	free(namelist);
+	return result;
+}
+
+int main(void)
+{
+	int rc;
+
+	if (map_mem("/dev/mem", 0, 0xA0000, 1) == 0)
+		fprintf(stderr, "PASS: /dev/mem 0x0-0xa0000 is readable\n");
+	else
+		fprintf(stderr, "FAIL: /dev/mem 0x0-0xa0000 not accessible\n");
+
+	/*
+	 * It's not safe to blindly read the VGA frame buffer.  If you know
+	 * how to poke the card the right way, it should respond, but it's
+	 * not safe in general.  Many machines, e.g., Intel chipsets, cover
+	 * up a non-responding card by just returning -1, but others will
+	 * report the failure as a machine check.
+	 */
+	if (map_mem("/dev/mem", 0xA0000, 0x20000, 0) == 0)
+		fprintf(stderr, "PASS: /dev/mem 0xa0000-0xc0000 is mappable\n");
+	else
+		fprintf(stderr, "FAIL: /dev/mem 0xa0000-0xc0000 not accessible\n");
+
+	if (map_mem("/dev/mem", 0xC0000, 0x40000, 1) == 0)
+		fprintf(stderr, "PASS: /dev/mem 0xc0000-0x100000 is readable\n");
+	else
+		fprintf(stderr, "FAIL: /dev/mem 0xc0000-0x100000 not accessible\n");
+
+	/*
+	 * Often you can map all the individual pieces above (0-0xA0000,
+	 * 0xA0000-0xC0000, and 0xC0000-0x100000), but can't map the whole
+	 * thing at once.  This is because the individual pieces use different
+	 * attributes, and there's no single attribute supported over the
+	 * whole region.
+	 */
+	rc = map_mem("/dev/mem", 0, 1024*1024, 0);
+	if (rc == 0)
+		fprintf(stderr, "PASS: /dev/mem 0x0-0x100000 is mappable\n");
+	else if (rc > 0)
+		fprintf(stderr, "PASS: /dev/mem 0x0-0x100000 not mappable\n");
+	else
+		fprintf(stderr, "FAIL: /dev/mem 0x0-0x100000 not accessible\n");
+
+	scan_tree("/sys/class/pci_bus", "legacy_mem", 0, 0xA0000, 1);
+	scan_tree("/sys/class/pci_bus", "legacy_mem", 0xA0000, 0x20000, 0);
+	scan_tree("/sys/class/pci_bus", "legacy_mem", 0xC0000, 0x40000, 1);
+	scan_tree("/sys/class/pci_bus", "legacy_mem", 0, 1024*1024, 0);
+
+	scan_rom("/sys/devices", "rom");
+
+	scan_tree("/proc/bus/pci", "??.?", 0, 0xA0000, 1);
+	scan_tree("/proc/bus/pci", "??.?", 0xA0000, 0x20000, 0);
+	scan_tree("/proc/bus/pci", "??.?", 0xC0000, 0x40000, 1);
+	scan_tree("/proc/bus/pci", "??.?", 0, 1024*1024, 0);
+
+	return rc;
+}
-- 
2.7.4
