From: James Morris <jmorris@namei.org>
Subject: [RFC][SECMARK userland 01/03] Add libselinux support
Date: Sun, 7 May 2006 11:42:22 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605071141020.8588@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@lists.samba.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:6289 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932188AbWEGPm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 May 2006 11:42:27 -0400
To: selinux@tycho.nsa.gov
In-Reply-To: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the infrastructure for linking iptables against 
libselinux, for use with the SECMARK target.  This is enabled by setting 
DO_SELINUX=1 in the build environment.


Signed-off-by: James Morris <jmorris@namei.org>

---

 Makefile            |   14 +++++++++++++-
 Rules.make          |   11 +++++++++--
 extensions/Makefile |   15 ++++++++++++++-
 3 files changed, 36 insertions(+), 4 deletions(-)

diff -purN -X dontdiff iptables.p/extensions/Makefile iptables.w/extensions/Makefile
--- iptables.p/extensions/Makefile	2006-04-25 20:11:00.000000000 -0400
+++ iptables.w/extensions/Makefile	2006-04-25 20:10:43.000000000 -0400
@@ -8,6 +8,11 @@
 PF_EXT_SLIB:=ah addrtype comment connlimit connmark conntrack dscp ecn esp hashlimit helper icmp iprange length limit mac mark multiport owner physdev pkttype policy realm rpc sctp standard state tcp tcpmss tos ttl udp unclean CLASSIFY CONNMARK DNAT DSCP ECN LOG MARK MASQUERADE MIRROR NETMAP NFQUEUE NOTRACK REDIRECT REJECT SAME SNAT TARPIT TCPMSS TOS TRACE TTL ULOG
 PF6_EXT_SLIB:=connmark eui64 hl icmp6 length limit mac mark multiport owner physdev policy standard state tcp udp CONNMARK HL LOG NFQUEUE MARK TRACE
 
+ifeq ($(DO_SELINUX), 1)
+PF_EXT_SE_SLIB:=
+PF6_EXT_SE_SLIB:=
+endif
+
 # Optionals
 PF_EXT_SLIB_OPTS:=$(foreach T,$(wildcard extensions/.*-test),$(shell KERNEL_DIR=$(KERNEL_DIR) $(T)))
 PF6_EXT_SLIB_OPTS:=$(foreach T,$(wildcard extensions/.*-test6),$(shell KERNEL_DIR=$(KERNEL_DIR) $(T)))
@@ -43,26 +48,34 @@ OPTIONALS+=$(patsubst %,IPv6:%,$(PF6_EXT
 
 ifndef NO_SHARED_LIBS
 SHARED_LIBS+=$(foreach T,$(PF_EXT_SLIB),extensions/libipt_$(T).so)
+SHARED_SE_LIBS+=$(foreach T,$(PF_EXT_SE_SLIB),extensions/libipt_$(T).so)
 EXTRA_INSTALLS+=$(foreach T, $(PF_EXT_SLIB), $(DESTDIR)$(LIBDIR)/iptables/libipt_$(T).so)
+EXTRA_INSTALLS+=$(foreach T, $(PF_EXT_SE_SLIB), $(DESTDIR)$(LIBDIR)/iptables/libipt_$(T).so)
 
 ifeq ($(DO_IPV6), 1)
 SHARED_LIBS+=$(foreach T,$(PF6_EXT_SLIB),extensions/libip6t_$(T).so)
+SHARED_SE_LIBS+=$(foreach T,$(PF6_EXT_SE_SLIB),extensions/libip6t_$(T).so)
 EXTRA_INSTALLS+=$(foreach T, $(PF6_EXT_SLIB), $(DESTDIR)$(LIBDIR)/iptables/libip6t_$(T).so)
+EXTRA_INSTALLS+=$(foreach T, $(PF6_EXT_SE_SLIB), $(DESTDIR)$(LIBDIR)/iptables/libip6t_$(T).so)
 endif
 else 	# NO_SHARED_LIBS
 EXT_OBJS+=$(foreach T,$(PF_EXT_SLIB),extensions/libipt_$(T).o)
+EXT_OBJS+=$(foreach T,$(PF_EXT_SE_SLIB),extensions/libipt_$(T).o)
 EXT_FUNC+=$(foreach T,$(PF_EXT_SLIB),ipt_$(T))
+EXT_FUNC+=$(foreach T,$(PF_EXT_SE_SLIB),ipt_$(T))
 EXT_OBJS+= extensions/initext.o
 ifeq ($(DO_IPV6), 1)
 EXT6_OBJS+=$(foreach T,$(PF6_EXT_SLIB),extensions/libip6t_$(T).o)
+EXT6_OBJS+=$(foreach T,$(PF6_EXT_SE_SLIB),extensions/libip6t_$(T).o)
 EXT6_FUNC+=$(foreach T,$(PF6_EXT_SLIB),ip6t_$(T))
+EXT6_FUNC+=$(foreach T,$(PF6_EXT_SE_SLIB),ip6t_$(T))
 EXT6_OBJS+= extensions/initext6.o
 endif	# DO_IPV6
 endif	# NO_SHARED_LIBS
 
 ifndef TOPLEVEL_INCLUDED
 local:
-	cd .. && $(MAKE) $(SHARED_LIBS)
+	cd .. && $(MAKE) $(SHARED_LIBS) $(SHARED_SE_LIBS)
 endif
 
 ifdef NO_SHARED_LIBS
diff -purN -X dontdiff iptables.p/Makefile iptables.w/Makefile
--- iptables.p/Makefile	2006-04-25 20:11:00.000000000 -0400
+++ iptables.w/Makefile	2006-04-25 01:16:43.000000000 -0400
@@ -31,6 +31,11 @@ ifeq ($(shell [ -f /usr/include/netinet/
 DO_IPV6:=1
 endif
 
+# Enable linking to libselinux via enviornment 'DO_SELINUX=1'
+ifndef DO_SELINUX
+DO_SELINUX=0
+endif
+
 COPT_FLAGS:=-O2
 CFLAGS:=$(COPT_FLAGS) -Wall -Wunused -I$(KERNEL_DIR)/include -Iinclude/ -DIPTABLES_VERSION=\"$(IPTABLES_VERSION)\" #-g -DDEBUG #-pg # -DIPTC_DEBUG
 
@@ -93,17 +98,24 @@ endif
 
 ifndef NO_SHARED_LIBS
 DEPFILES = $(SHARED_LIBS:%.so=%.d)
+DEPFILES += $(SHARED_SE_LIBS:%.so=%.d)
 SH_CFLAGS:=$(CFLAGS) -fPIC
 STATIC_LIBS  =
 STATIC6_LIBS =
 LDFLAGS      = -rdynamic
 LDLIBS       = -ldl -lnsl
+ifeq ($(DO_SELINUX), 1)
+LDLIBS       += -lselinux
+endif
 else
 DEPFILES = $(EXT_OBJS:%.o=%.d)
 STATIC_LIBS  = extensions/libext.a
 STATIC6_LIBS = extensions/libext6.a
 LDFLAGS      = -static
-LDLIBS       =
+LDLIBS	     =
+ifeq ($(DO_SELINUX), 1)
+LDLIBS       += -lselinux
+endif
 endif
 
 .PHONY: default
diff -purN -X dontdiff iptables.p/Rules.make iptables.w/Rules.make
--- iptables.p/Rules.make	2006-04-25 20:11:00.000000000 -0400
+++ iptables.w/Rules.make	2006-04-25 01:16:43.000000000 -0400
@@ -1,12 +1,12 @@
 #! /usr/bin/make
 
-all: $(SHARED_LIBS) $(EXTRAS)
+all: $(SHARED_LIBS) $(SHARED_SE_LIBS) $(EXTRAS)
 
 experimental: $(EXTRAS_EXP)
 
 # Have to handle extensions which no longer exist.
 clean: $(EXTRA_CLEANS)
-	rm -f $(SHARED_LIBS) $(EXTRAS) $(EXTRAS_EXP) $(SHARED_LIBS:%.so=%_sh.o)
+	rm -f $(SHARED_LIBS) $(SHARED_SE_LIBS) $(EXTRAS) $(EXTRAS_EXP) $(SHARED_LIBS:%.so=%_sh.o) $(SHARED_SE_LIBS:%.so=%_sh.o)
 	rm -f extensions/initext.c extensions/initext6.c
 	@find . -name '*.[ao]' -o -name '*.so' | xargs rm -f
 
@@ -33,6 +33,13 @@ $(SHARED_LIBS:%.so=%.d): %.d: %.c
 $(SHARED_LIBS): %.so : %_sh.o
 	$(LD) -shared $(EXT_LDFLAGS) -o $@ $<
 
+$(SHARED_SE_LIBS:%.so=%.d): %.d: %.c
+	@-$(CC) -M -MG $(CFLAGS) $< | \
+		sed -e 's@^.*\.o:@$*.d $*_sh.o:@' > $@
+
+$(SHARED_SE_LIBS): %.so : %_sh.o
+	$(LD) -shared $(EXT_LDFLAGS) -o $@ $< $(LDLIBS)
+
 %_sh.o : %.c
 	$(CC) $(SH_CFLAGS) -o $@ -c $<
 
