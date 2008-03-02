From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Sun, 2 Mar 2008 12:58:28 +0100
Message-ID: <20080302115828.GA15820@uranus.ravnborg.org>
References: <20080228014125.GI3078@tuxdriver.com> <20080229214240.GH3234@tuxdriver.com> <20080301130133.GA14250@uranus.ravnborg.org> <200803011651.13652.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	gordonfarquharson@gmail.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:35911 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750765AbYCBL6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Mar 2008 06:58:17 -0500
Content-Disposition: inline
In-Reply-To: <200803011651.13652.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 01, 2008 at 04:51:12PM +0100, Michael Buesch wrote:
> On Saturday 01 March 2008, Sam Ravnborg wrote:
> > > This version seems to work, but it is a bit chatty when CROSS_COMPILE
> > > is set and you build lots of modules...thoughts?
> > 
> > We cannot use CROSS_COMPILE to detect a cross build as CROSS_COMPILE
> > is used used to select different gcc versions, cccache etc.
> > The only relaiably way to detect a cross build is to check
> > is ARCH != modified uname -m arch.
> > So this check would have to be done in the top-level Makefile.
> > 
> > And that for shaving 6 bytes of a structure..
> 
> Wrong. For maintaining userspace ABI compatibility.
NEws to me - that argument I did not see when I posted my previous mail
about possible worarounds.
Find below a patch that detect when we do a cross build and thus ignore
the check.

This is NOT tested as I do not have access to my dev box atm.
I have only tested I could build a i386 kernel.

So please let me know if this works and then I can push it upstrem
hopefully already by tomorrow.

Note: I decided to name the variable KBUILD_BUILDHOST as this is more
descriptive then SUBARCH. We can later clean up the naming and get rid
of SUBARCH but I refrained from this to make the pacht minimal.

	Sam

diff --git a/Makefile b/Makefile
index a229784..de28306 100644
--- a/Makefile
+++ b/Makefile
@@ -189,7 +189,7 @@ SUBARCH := $(shell uname -m | sed -e s/i.86/i386/ -e s/sun4u/sparc64/ \
 # Alternatively CROSS_COMPILE can be set in the environment.
 # Default value for CROSS_COMPILE is not to prefix executables
 # Note: Some architectures assign CROSS_COMPILE in their arch/*/Makefile
-
+export KBUILD_BUILDHOST := $(SUBARCH)
 ARCH		?= $(SUBARCH)
 CROSS_COMPILE	?=
 
diff --git a/scripts/Makefile.modpost b/scripts/Makefile.modpost
index cfc004e..2d20640 100644
--- a/scripts/Makefile.modpost
+++ b/scripts/Makefile.modpost
@@ -58,6 +58,9 @@ modules   := $(patsubst %.o,%.ko, $(wildcard $(__modules:.ko=.o)))
 # Stop after building .o files if NOFINAL is set. Makes compile tests quicker
 _modpost: $(if $(KBUILD_MODPOST_NOFINAL), $(modules:.ko:.o),$(modules))
 
+ifneq ($(KBUILD_BUILDHOST),$(ARCH))
+        cross_build := 1
+endif
 
 # Step 2), invoke modpost
 #  Includes step 3,4
@@ -70,7 +73,8 @@ modpost = scripts/mod/modpost                    \
  $(if $(CONFIG_DEBUG_SECTION_MISMATCH),,-S)      \
  $(if $(CONFIG_MARKERS),-K $(kernelmarkersfile)) \
  $(if $(CONFIG_MARKERS),-M $(markersfile))	 \
- $(if $(KBUILD_EXTMOD)$(KBUILD_MODPOST_WARN),-w)
+ $(if $(KBUILD_EXTMOD)$(KBUILD_MODPOST_WARN),-w) \
+ $(if $(cross_build),-c)
 
 quiet_cmd_modpost = MODPOST $(words $(filter-out vmlinux FORCE, $^)) modules
       cmd_modpost = $(modpost) -s
diff --git a/scripts/mod/file2alias.c b/scripts/mod/file2alias.c
index 9ddf944..348d868 100644
--- a/scripts/mod/file2alias.c
+++ b/scripts/mod/file2alias.c
@@ -51,11 +51,13 @@ do {                                                            \
                 sprintf(str + strlen(str), "*");                \
 } while(0)
 
+unsigned int cross_build = 0;
 /**
  * Check that sizeof(device_id type) are consistent with size of section
  * in .o file. If in-consistent then userspace and kernel does not agree
  * on actual size which is a bug.
  * Also verify that the final entry in the table is all zeros.
+ * Ignore both checks if build host differ from target host and size differs.
  **/
 static void device_id_check(const char *modname, const char *device_id,
 			    unsigned long size, unsigned long id_size,
@@ -64,6 +66,8 @@ static void device_id_check(const char *modname, const char *device_id,
 	int i;
 
 	if (size % id_size || size < id_size) {
+		if (cross_build != 0)
+			return;
 		fatal("%s: sizeof(struct %s_device_id)=%lu is not a modulo "
 		      "of the size of section __mod_%s_device_table=%lu.\n"
 		      "Fix definition of struct %s_device_id "
diff --git a/scripts/mod/modpost.c b/scripts/mod/modpost.c
index 695b5d6..110cf24 100644
--- a/scripts/mod/modpost.c
+++ b/scripts/mod/modpost.c
@@ -2026,7 +2026,7 @@ int main(int argc, char **argv)
 	int opt;
 	int err;
 
-	while ((opt = getopt(argc, argv, "i:I:msSo:awM:K:")) != -1) {
+	while ((opt = getopt(argc, argv, "i:I:cmsSo:awM:K:")) != -1) {
 		switch (opt) {
 		case 'i':
 			kernel_read = optarg;
@@ -2035,6 +2035,9 @@ int main(int argc, char **argv)
 			module_read = optarg;
 			external_module = 1;
 			break;
+		case 'c':
+			cross_build = 1;
+			break;
 		case 'm':
 			modversions = 1;
 			break;
diff --git a/scripts/mod/modpost.h b/scripts/mod/modpost.h
index 565c587..09f58e3 100644
--- a/scripts/mod/modpost.h
+++ b/scripts/mod/modpost.h
@@ -135,6 +135,7 @@ struct elf_info {
 };
 
 /* file2alias.c */
+extern unsigned int cross_build;
 void handle_moddevtable(struct module *mod, struct elf_info *info,
 			Elf_Sym *sym, const char *symname);
 void add_moddevtable(struct buffer *buf, struct module *mod);
