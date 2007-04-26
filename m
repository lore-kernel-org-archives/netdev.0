From: David Howells <dhowells@redhat.com>
Subject: [PATCH 07/14] AF_RXRPC: Make the in-kernel AFS filesystem use
	AF_RXRPC [net-2.6]
Date: Thu, 26 Apr 2007 20:54:52 +0100
Message-ID: <20070426195451.24531.90887.stgit@warthog.cambridge.redhat.com>
References: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031466AbXDZTzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 15:55:21 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3QJtJdA029081
	for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 15:55:19 -0400
In-Reply-To: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the in-kernel AFS filesystem use AF_RXRPC instead of the old RxRPC=
 code.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 fs/Kconfig          |   13 +
 fs/afs/Makefile     |    3=20
 fs/afs/afs.h        |  105 +++++
 fs/afs/afs_cm.h     |   28 +
 fs/afs/afs_fs.h     |   41 ++
 fs/afs/afs_vl.h     |   84 ++++
 fs/afs/cache.c      |  256 +++++++++++
 fs/afs/callback.c   |  469 ++++++++++++++++-----
 fs/afs/cell.c       |  344 +++------------
 fs/afs/cell.h       |   70 ---
 fs/afs/cmservice.c  |  781 ++++++++++-------------------------
 fs/afs/cmservice.h  |   28 -
 fs/afs/dir.c        |  286 ++++++++-----
 fs/afs/errors.h     |   36 --
 fs/afs/file.c       |   39 --
 fs/afs/fsclient.c   | 1042 ++++++++++++++-----------------------------=
---
 fs/afs/fsclient.h   |   54 --
 fs/afs/inode.c      |  107 ++---
 fs/afs/internal.h   |  599 ++++++++++++++++++++++++--
 fs/afs/kafsasyncd.c |  247 -----------
 fs/afs/kafsasyncd.h |   50 --
 fs/afs/kafstimod.c  |  194 ---------
 fs/afs/kafstimod.h  |   45 --
 fs/afs/main.c       |  135 +-----
 fs/afs/misc.c       |   11=20
 fs/afs/mntpt.c      |  106 +++--
 fs/afs/mount.h      |   23 -
 fs/afs/proc.c       |   73 ++-
 fs/afs/rxrpc.c      |  666 +++++++++++++++++++++++++++++
 fs/afs/server.c     |  624 ++++++++++------------------
 fs/afs/server.h     |   97 ----
 fs/afs/super.c      |  106 ++---
 fs/afs/super.h      |   39 --
 fs/afs/transport.h  |   21 -
 fs/afs/types.h      |  109 -----
 fs/afs/vlclient.c   |  709 +++++--------------------------
 fs/afs/vlclient.h   |   85 ----
 fs/afs/vlocation.c  | 1153 +++++++++++++++++++++----------------------=
--------
 fs/afs/vnode.c      |  388 +++++++++--------
 fs/afs/vnode.h      |   84 ----
 fs/afs/volume.c     |  141 ++----
 fs/afs/volume.h     |  126 ------
 42 files changed, 4194 insertions(+), 5423 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 3c4886b..075c999 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -2019,7 +2019,7 @@ config CODA_FS_OLD_API
 config AFS_FS
 	tristate "Andrew File System support (AFS) (EXPERIMENTAL)"
 	depends on INET && EXPERIMENTAL
-	select RXRPC
+	select AF_RXRPC
 	help
 	  If you say Y here, you will get an experimental Andrew File System
 	  driver. It currently only supports unsecured read-only AFS access.
@@ -2028,6 +2028,17 @@ config AFS_FS
=20
 	  If unsure, say N.
=20
+config AFS_DEBUG
+	bool "AFS dynamic debugging"
+	depends on AFS_FS
+	help
+	  Say Y here to make runtime controllable debugging messages appear.
+
+	  See <file:Documentation/filesystems/afs.txt> for more information.
+
+	  If unsure, say N.
+
+
 config RXRPC
 	tristate
=20
diff --git a/fs/afs/Makefile b/fs/afs/Makefile
index 8e71973..66bdc21 100644
--- a/fs/afs/Makefile
+++ b/fs/afs/Makefile
@@ -10,12 +10,11 @@ kafs-objs :=3D \
 	file.o \
 	fsclient.o \
 	inode.o \
-	kafsasyncd.o \
-	kafstimod.o \
 	main.o \
 	misc.o \
 	mntpt.o \
 	proc.o \
+	rxrpc.o \
 	server.o \
 	super.o \
 	vlclient.o \
diff --git a/fs/afs/afs.h b/fs/afs/afs.h
new file mode 100644
index 0000000..0362e11
--- /dev/null
+++ b/fs/afs/afs.h
@@ -0,0 +1,105 @@
+/* AFS common types
+ *
+ * Copyright (C) 2002, 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef AFS_H
+#define AFS_H
+
+#include <linux/in.h>
+
+typedef unsigned			afs_volid_t;
+typedef unsigned			afs_vnodeid_t;
+typedef unsigned long long		afs_dataversion_t;
+
+typedef enum {
+	AFSVL_RWVOL,			/* read/write volume */
+	AFSVL_ROVOL,			/* read-only volume */
+	AFSVL_BACKVOL,			/* backup volume */
+} __attribute__((packed)) afs_voltype_t;
+
+typedef enum {
+	AFS_FTYPE_INVALID	=3D 0,
+	AFS_FTYPE_FILE		=3D 1,
+	AFS_FTYPE_DIR		=3D 2,
+	AFS_FTYPE_SYMLINK	=3D 3,
+} afs_file_type_t;
+
+/*
+ * AFS file identifier
+ */
+struct afs_fid {
+	afs_volid_t	vid;		/* volume ID */
+	afs_vnodeid_t	vnode;		/* file index within volume */
+	unsigned	unique;		/* unique ID number (file index version) */
+};
+
+/*
+ * AFS callback notification
+ */
+typedef enum {
+	AFSCM_CB_UNTYPED	=3D 0,	/* no type set on CB break */
+	AFSCM_CB_EXCLUSIVE	=3D 1,	/* CB exclusive to CM [not implemented] */
+	AFSCM_CB_SHARED		=3D 2,	/* CB shared by other CM's */
+	AFSCM_CB_DROPPED	=3D 3,	/* CB promise cancelled by file server */
+} afs_callback_type_t;
+
+struct afs_callback {
+	struct afs_fid		fid;		/* file identifier */
+	unsigned		version;	/* callback version */
+	unsigned		expiry;		/* time at which expires */
+	afs_callback_type_t	type;		/* type of callback */
+};
+
+#define AFSCBMAX 50	/* maximum callbacks transferred per bulk op */
+
+/*
+ * AFS volume information
+ */
+struct afs_volume_info {
+	afs_volid_t		vid;		/* volume ID */
+	afs_voltype_t		type;		/* type of this volume */
+	afs_volid_t		type_vids[5];	/* volume ID's for possible types for this=
 vol */
+=09
+	/* list of fileservers serving this volume */
+	size_t			nservers;	/* number of entries used in servers[] */
+	struct {
+		struct in_addr	addr;		/* fileserver address */
+	} servers[8];
+};
+
+/*
+ * AFS file status information
+ */
+struct afs_file_status {
+	unsigned		if_version;	/* interface version */
+#define AFS_FSTATUS_VERSION	1
+
+	afs_file_type_t		type;		/* file type */
+	unsigned		nlink;		/* link count */
+	size_t			size;		/* file size */
+	afs_dataversion_t	data_version;	/* current data version */
+	unsigned		author;		/* author ID */
+	unsigned		owner;		/* owner ID */
+	unsigned		caller_access;	/* access rights for authenticated caller */
+	unsigned		anon_access;	/* access rights for unauthenticated caller */
+	umode_t			mode;		/* UNIX mode */
+	struct afs_fid		parent;		/* parent file ID */
+	time_t			mtime_client;	/* last time client changed data */
+	time_t			mtime_server;	/* last time server changed data */
+};
+
+/*
+ * AFS volume synchronisation information
+ */
+struct afs_volsync {
+	time_t			creation;	/* volume creation time */
+};
+
+#endif /* AFS_H */
diff --git a/fs/afs/afs_cm.h b/fs/afs/afs_cm.h
new file mode 100644
index 0000000..7c8e3d4
--- /dev/null
+++ b/fs/afs/afs_cm.h
@@ -0,0 +1,28 @@
+/* AFS Cache Manager definitions
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef AFS_CM_H
+#define AFS_CM_H
+
+#define AFS_CM_PORT		7001	/* AFS file server port */
+#define CM_SERVICE		1	/* AFS File Service ID */
+
+enum AFS_CM_Operations {
+	CBCallBack		=3D 204,	/* break callback promises */
+	CBInitCallBackState	=3D 205,	/* initialise callback state */
+	CBProbe			=3D 206,	/* probe client */
+	CBGetLock		=3D 207,	/* get contents of CM lock table */
+	CBGetCE			=3D 208,	/* get cache file description */
+	CBGetXStatsVersion	=3D 209,	/* get version of extended statistics */
+	CBGetXStats		=3D 210,	/* get contents of extended statistics data */
+};
+
+#endif /* AFS_FS_H */
diff --git a/fs/afs/afs_fs.h b/fs/afs/afs_fs.h
new file mode 100644
index 0000000..fd38595
--- /dev/null
+++ b/fs/afs/afs_fs.h
@@ -0,0 +1,41 @@
+/* AFS File Service definitions
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef AFS_FS_H
+#define AFS_FS_H
+
+#define AFS_FS_PORT		7000	/* AFS file server port */
+#define FS_SERVICE		1	/* AFS File Service ID */
+
+enum AFS_FS_Operations {
+	FSFETCHSTATUS		=3D 132,	/* AFS Fetch file status */
+	FSFETCHDATA		=3D 130,	/* AFS Fetch file data */
+	FSGIVEUPCALLBACKS	=3D 147,	/* AFS Discard callback promises */
+	FSGETVOLUMEINFO		=3D 148,	/* AFS Get root volume information */
+	FSGETROOTVOLUME		=3D 151,	/* AFS Get root volume name */
+	FSLOOKUP		=3D 161	/* AFS lookup file in directory */
+};
+
+enum AFS_FS_Errors {
+	VSALVAGE	=3D 101,	/* volume needs salvaging */
+	VNOVNODE	=3D 102,	/* no such file/dir (vnode) */
+	VNOVOL		=3D 103,	/* no such volume or volume unavailable */
+	VVOLEXISTS	=3D 104,	/* volume name already exists */
+	VNOSERVICE	=3D 105,	/* volume not currently in service */
+	VOFFLINE	=3D 106,	/* volume is currently offline (more info available=
 [VVL-spec]) */
+	VONLINE		=3D 107,	/* volume is already online */
+	VDISKFULL	=3D 108,	/* disk partition is full */
+	VOVERQUOTA	=3D 109,	/* volume's maximum quota exceeded */
+	VBUSY		=3D 110,	/* volume is temporarily unavailable */
+	VMOVED		=3D 111,	/* volume moved to new server - ask this FS where */
+};
+
+#endif /* AFS_FS_H */
diff --git a/fs/afs/afs_vl.h b/fs/afs/afs_vl.h
new file mode 100644
index 0000000..453efa2
--- /dev/null
+++ b/fs/afs/afs_vl.h
@@ -0,0 +1,84 @@
+/* AFS Volume Location Service client interface
+ *
+ * Copyright (C) 2002, 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef AFS_VL_H
+#define AFS_VL_H
+
+#include "afs.h"
+
+#define AFS_VL_PORT		7003	/* volume location service port */
+#define VL_SERVICE		52	/* RxRPC service ID for the Volume Location ser=
vice */
+
+enum AFSVL_Operations {
+	VLGETENTRYBYID		=3D 503,	/* AFS Get Cache Entry By ID operation ID */
+	VLGETENTRYBYNAME	=3D 504,	/* AFS Get Cache Entry By Name operation ID=
 */
+	VLPROBE			=3D 514,	/* AFS Probe Volume Location Service operation ID =
*/
+};
+
+enum AFSVL_Errors {
+	AFSVL_IDEXIST 		=3D 363520,	/* Volume Id entry exists in vl database =
*/
+	AFSVL_IO 		=3D 363521,	/* I/O related error */
+	AFSVL_NAMEEXIST 	=3D 363522,	/* Volume name entry exists in vl databa=
se */
+	AFSVL_CREATEFAIL 	=3D 363523,	/* Internal creation failure */
+	AFSVL_NOENT 		=3D 363524,	/* No such entry */
+	AFSVL_EMPTY 		=3D 363525,	/* Vl database is empty */
+	AFSVL_ENTDELETED 	=3D 363526,	/* Entry is deleted (soft delete) */
+	AFSVL_BADNAME 		=3D 363527,	/* Volume name is illegal */
+	AFSVL_BADINDEX 		=3D 363528,	/* Index is out of range */
+	AFSVL_BADVOLTYPE 	=3D 363529,	/* Bad volume type */
+	AFSVL_BADSERVER 	=3D 363530,	/* Illegal server number (out of range) =
*/
+	AFSVL_BADPARTITION 	=3D 363531,	/* Bad partition number */
+	AFSVL_REPSFULL 		=3D 363532,	/* Run out of space for Replication site=
s */
+	AFSVL_NOREPSERVER 	=3D 363533,	/* No such Replication server site exi=
sts */
+	AFSVL_DUPREPSERVER 	=3D 363534,	/* Replication site already exists */
+	AFSVL_RWNOTFOUND 	=3D 363535,	/* Parent R/W entry not found */
+	AFSVL_BADREFCOUNT 	=3D 363536,	/* Illegal Reference Count number */
+	AFSVL_SIZEEXCEEDED 	=3D 363537,	/* Vl size for attributes exceeded */
+	AFSVL_BADENTRY 		=3D 363538,	/* Bad incoming vl entry */
+	AFSVL_BADVOLIDBUMP 	=3D 363539,	/* Illegal max volid increment */
+	AFSVL_IDALREADYHASHED 	=3D 363540,	/* RO/BACK id already hashed */
+	AFSVL_ENTRYLOCKED 	=3D 363541,	/* Vl entry is already locked */
+	AFSVL_BADVOLOPER 	=3D 363542,	/* Bad volume operation code */
+	AFSVL_BADRELLOCKTYPE 	=3D 363543,	/* Bad release lock type */
+	AFSVL_RERELEASE 	=3D 363544,	/* Status report: last release was abort=
ed */
+	AFSVL_BADSERVERFLAG 	=3D 363545,	/* Invalid replication site server =B0=
ag */
+	AFSVL_PERM 		=3D 363546,	/* No permission access */
+	AFSVL_NOMEM 		=3D 363547,	/* malloc/realloc failed to alloc enough me=
mory */
+};
+
+/*
+ * maps to "struct vldbentry" in vvl-spec.pdf
+ */
+struct afs_vldbentry {
+	char		name[65];		/* name of volume (with NUL char) */
+	afs_voltype_t	type;			/* volume type */
+	unsigned	num_servers;		/* num servers that hold instances of this vol=
 */
+	unsigned	clone_id;		/* cloning ID */
+
+	unsigned	flags;
+#define AFS_VLF_RWEXISTS	0x1000		/* R/W volume exists */
+#define AFS_VLF_ROEXISTS	0x2000		/* R/O volume exists */
+#define AFS_VLF_BACKEXISTS	0x4000		/* backup volume exists */
+
+	afs_volid_t	volume_ids[3];		/* volume IDs */
+
+	struct {
+		struct in_addr	addr;		/* server address */
+		unsigned	partition;	/* partition ID on this server */
+		unsigned	flags;		/* server specific flags */
+#define AFS_VLSF_NEWREPSITE	0x0001	/* unused */
+#define AFS_VLSF_ROVOL		0x0002	/* this server holds a R/O instance of =
the volume */
+#define AFS_VLSF_RWVOL		0x0004	/* this server holds a R/W instance of =
the volume */
+#define AFS_VLSF_BACKVOL	0x0008	/* this server holds a backup instance=
 of the volume */
+	} servers[8];
+};
+
+#endif /* AFS_VL_H */
diff --git a/fs/afs/cache.c b/fs/afs/cache.c
new file mode 100644
index 0000000..de0d7de
--- /dev/null
+++ b/fs/afs/cache.c
@@ -0,0 +1,256 @@
+/* AFS caching stuff
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifdef AFS_CACHING_SUPPORT
+static cachefs_match_val_t afs_cell_cache_match(void *target,
+						const void *entry);
+static void afs_cell_cache_update(void *source, void *entry);
+
+struct cachefs_index_def afs_cache_cell_index_def =3D {
+	.name			=3D "cell_ix",
+	.data_size		=3D sizeof(struct afs_cache_cell),
+	.keys[0]		=3D { CACHEFS_INDEX_KEYS_ASCIIZ, 64 },
+	.match			=3D afs_cell_cache_match,
+	.update			=3D afs_cell_cache_update,
+};
+#endif
+
+/*
+ * match a cell record obtained from the cache
+ */
+#ifdef AFS_CACHING_SUPPORT
+static cachefs_match_val_t afs_cell_cache_match(void *target,
+						const void *entry)
+{
+	const struct afs_cache_cell *ccell =3D entry;
+	struct afs_cell *cell =3D target;
+
+	_enter("{%s},{%s}", ccell->name, cell->name);
+
+	if (strncmp(ccell->name, cell->name, sizeof(ccell->name)) =3D=3D 0) {
+		_leave(" =3D SUCCESS");
+		return CACHEFS_MATCH_SUCCESS;
+	}
+
+	_leave(" =3D FAILED");
+	return CACHEFS_MATCH_FAILED;
+}
+#endif
+
+/*
+ * update a cell record in the cache
+ */
+#ifdef AFS_CACHING_SUPPORT
+static void afs_cell_cache_update(void *source, void *entry)
+{
+	struct afs_cache_cell *ccell =3D entry;
+	struct afs_cell *cell =3D source;
+
+	_enter("%p,%p", source, entry);
+
+	strncpy(ccell->name, cell->name, sizeof(ccell->name));
+
+	memcpy(ccell->vl_servers,
+	       cell->vl_addrs,
+	       min(sizeof(ccell->vl_servers), sizeof(cell->vl_addrs)));
+
+}
+#endif
+
+#ifdef AFS_CACHING_SUPPORT
+static cachefs_match_val_t afs_vlocation_cache_match(void *target,
+						     const void *entry);
+static void afs_vlocation_cache_update(void *source, void *entry);
+
+struct cachefs_index_def afs_vlocation_cache_index_def =3D {
+	.name		=3D "vldb",
+	.data_size	=3D sizeof(struct afs_cache_vlocation),
+	.keys[0]	=3D { CACHEFS_INDEX_KEYS_ASCIIZ, 64 },
+	.match		=3D afs_vlocation_cache_match,
+	.update		=3D afs_vlocation_cache_update,
+};
+#endif
+
+/*
+ * match a VLDB record stored in the cache
+ * - may also load target from entry
+ */
+#ifdef AFS_CACHING_SUPPORT
+static cachefs_match_val_t afs_vlocation_cache_match(void *target,
+						     const void *entry)
+{
+	const struct afs_cache_vlocation *vldb =3D entry;
+	struct afs_vlocation *vlocation =3D target;
+
+	_enter("{%s},{%s}", vlocation->vldb.name, vldb->name);
+
+	if (strncmp(vlocation->vldb.name, vldb->name, sizeof(vldb->name)) =3D=
=3D 0
+	    ) {
+		if (!vlocation->valid ||
+		    vlocation->vldb.rtime =3D=3D vldb->rtime
+		    ) {
+			vlocation->vldb =3D *vldb;
+			vlocation->valid =3D 1;
+			_leave(" =3D SUCCESS [c->m]");
+			return CACHEFS_MATCH_SUCCESS;
+		} else if (memcmp(&vlocation->vldb, vldb, sizeof(*vldb)) !=3D 0) {
+			/* delete if VIDs for this name differ */
+			if (memcmp(&vlocation->vldb.vid,
+				   &vldb->vid,
+				   sizeof(vldb->vid)) !=3D 0) {
+				_leave(" =3D DELETE");
+				return CACHEFS_MATCH_SUCCESS_DELETE;
+			}
+
+			_leave(" =3D UPDATE");
+			return CACHEFS_MATCH_SUCCESS_UPDATE;
+		} else {
+			_leave(" =3D SUCCESS");
+			return CACHEFS_MATCH_SUCCESS;
+		}
+	}
+
+	_leave(" =3D FAILED");
+	return CACHEFS_MATCH_FAILED;
+}
+#endif
+
+/*
+ * update a VLDB record stored in the cache
+ */
+#ifdef AFS_CACHING_SUPPORT
+static void afs_vlocation_cache_update(void *source, void *entry)
+{
+	struct afs_cache_vlocation *vldb =3D entry;
+	struct afs_vlocation *vlocation =3D source;
+
+	_enter("");
+
+	*vldb =3D vlocation->vldb;
+}
+#endif
+
+#ifdef AFS_CACHING_SUPPORT
+static cachefs_match_val_t afs_volume_cache_match(void *target,
+						  const void *entry);
+static void afs_volume_cache_update(void *source, void *entry);
+
+struct cachefs_index_def afs_volume_cache_index_def =3D {
+	.name		=3D "volume",
+	.data_size	=3D sizeof(struct afs_cache_vhash),
+	.keys[0]	=3D { CACHEFS_INDEX_KEYS_BIN, 1 },
+	.keys[1]	=3D { CACHEFS_INDEX_KEYS_BIN, 1 },
+	.match		=3D afs_volume_cache_match,
+	.update		=3D afs_volume_cache_update,
+};
+#endif
+
+/*
+ * match a volume hash record stored in the cache
+ */
+#ifdef AFS_CACHING_SUPPORT
+static cachefs_match_val_t afs_volume_cache_match(void *target,
+						  const void *entry)
+{
+	const struct afs_cache_vhash *vhash =3D entry;
+	struct afs_volume *volume =3D target;
+
+	_enter("{%u},{%u}", volume->type, vhash->vtype);
+
+	if (volume->type =3D=3D vhash->vtype) {
+		_leave(" =3D SUCCESS");
+		return CACHEFS_MATCH_SUCCESS;
+	}
+
+	_leave(" =3D FAILED");
+	return CACHEFS_MATCH_FAILED;
+}
+#endif
+
+/*
+ * update a volume hash record stored in the cache
+ */
+#ifdef AFS_CACHING_SUPPORT
+static void afs_volume_cache_update(void *source, void *entry)
+{
+	struct afs_cache_vhash *vhash =3D entry;
+	struct afs_volume *volume =3D source;
+
+	_enter("");
+
+	vhash->vtype =3D volume->type;
+}
+#endif
+
+#ifdef AFS_CACHING_SUPPORT
+static cachefs_match_val_t afs_vnode_cache_match(void *target,
+						 const void *entry);
+static void afs_vnode_cache_update(void *source, void *entry);
+
+struct cachefs_index_def afs_vnode_cache_index_def =3D {
+	.name		=3D "vnode",
+	.data_size	=3D sizeof(struct afs_cache_vnode),
+	.keys[0]	=3D { CACHEFS_INDEX_KEYS_BIN, 4 },
+	.match		=3D afs_vnode_cache_match,
+	.update		=3D afs_vnode_cache_update,
+};
+#endif
+
+/*
+ * match a vnode record stored in the cache
+ */
+#ifdef AFS_CACHING_SUPPORT
+static cachefs_match_val_t afs_vnode_cache_match(void *target,
+						 const void *entry)
+{
+	const struct afs_cache_vnode *cvnode =3D entry;
+	struct afs_vnode *vnode =3D target;
+
+	_enter("{%x,%x,%Lx},{%x,%x,%Lx}",
+	       vnode->fid.vnode,
+	       vnode->fid.unique,
+	       vnode->status.version,
+	       cvnode->vnode_id,
+	       cvnode->vnode_unique,
+	       cvnode->data_version);
+
+	if (vnode->fid.vnode !=3D cvnode->vnode_id) {
+		_leave(" =3D FAILED");
+		return CACHEFS_MATCH_FAILED;
+	}
+
+	if (vnode->fid.unique !=3D cvnode->vnode_unique ||
+	    vnode->status.version !=3D cvnode->data_version) {
+		_leave(" =3D DELETE");
+		return CACHEFS_MATCH_SUCCESS_DELETE;
+	}
+
+	_leave(" =3D SUCCESS");
+	return CACHEFS_MATCH_SUCCESS;
+}
+#endif
+
+/*
+ * update a vnode record stored in the cache
+ */
+#ifdef AFS_CACHING_SUPPORT
+static void afs_vnode_cache_update(void *source, void *entry)
+{
+	struct afs_cache_vnode *cvnode =3D entry;
+	struct afs_vnode *vnode =3D source;
+
+	_enter("");
+
+	cvnode->vnode_id	=3D vnode->fid.vnode;
+	cvnode->vnode_unique	=3D vnode->fid.unique;
+	cvnode->data_version	=3D vnode->status.version;
+}
+#endif
diff --git a/fs/afs/callback.c b/fs/afs/callback.c
index 26a48fe..6112155 100644
--- a/fs/afs/callback.c
+++ b/fs/afs/callback.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2002 Red Hat, Inc. All rights reserved.
+ * Copyright (c) 2002, 2007 Red Hat, Inc. All rights reserved.
  *
  * This software may be freely redistributed under the terms of the
  * GNU General Public License.
@@ -16,83 +16,182 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
-#include "server.h"
-#include "vnode.h"
+#include <linux/circ_buf.h>
 #include "internal.h"
-#include "cmservice.h"
+
+unsigned afs_vnode_update_timeout =3D 10;
+
+#define afs_breakring_space(server) \
+	CIRC_SPACE((server)->cb_break_head, (server)->cb_break_tail,	\
+		   ARRAY_SIZE((server)->cb_break))
+
+//static void afs_callback_updater(struct work_struct *);
+
+static struct workqueue_struct *afs_callback_update_worker;
=20
 /*
  * allow the fileserver to request callback state (re-)initialisation
  */
-int SRXAFSCM_InitCallBackState(struct afs_server *server)
+void afs_init_callback_state(struct afs_server *server)
 {
-	struct list_head callbacks;
+	struct afs_vnode *vnode;
=20
-	_enter("%p", server);
+	_enter("{%p}", server);
=20
-	INIT_LIST_HEAD(&callbacks);
-
-	/* transfer the callback list from the server to a temp holding area =
*/
 	spin_lock(&server->cb_lock);
=20
-	list_add(&callbacks, &server->cb_promises);
-	list_del_init(&server->cb_promises);
+	/* kill all the promises on record from this server */
+	while (!RB_EMPTY_ROOT(&server->cb_promises)) {
+		vnode =3D rb_entry(server->cb_promises.rb_node,
+				 struct afs_vnode, cb_promise);
+		printk("\nUNPROMISE on %p\n", vnode);
+		rb_erase(&vnode->cb_promise, &server->cb_promises);
+		vnode->cb_promised =3D false;
+	}
=20
-	/* munch our way through the list, grabbing the inode, dropping all t=
he
-	 * locks and regetting them in the right order
-	 */
-	while (!list_empty(&callbacks)) {
-		struct afs_vnode *vnode;
-		struct inode *inode;
+	spin_unlock(&server->cb_lock);
+	_leave("");
+}
=20
-		vnode =3D list_entry(callbacks.next, struct afs_vnode, cb_link);
-		list_del_init(&vnode->cb_link);
+/*
+ * handle the data invalidation side of a callback being broken
+ */
+void afs_broken_callback_work(struct work_struct *work)
+{
+	struct afs_vnode *vnode =3D
+		container_of(work, struct afs_vnode, cb_broken_work);
=20
-		/* try and grab the inode - may fail */
-		inode =3D igrab(AFS_VNODE_TO_I(vnode));
-		if (inode) {
-			int release =3D 0;
+	_enter("");
=20
-			spin_unlock(&server->cb_lock);
-			spin_lock(&vnode->lock);
+	if (test_bit(AFS_VNODE_DELETED, &vnode->flags))
+		return;
=20
-			if (vnode->cb_server =3D=3D server) {
-				vnode->cb_server =3D NULL;
-				afs_kafstimod_del_timer(&vnode->cb_timeout);
-				spin_lock(&afs_cb_hash_lock);
-				list_del_init(&vnode->cb_hash_link);
-				spin_unlock(&afs_cb_hash_lock);
-				release =3D 1;
-			}
+	/* we're only interested in dealing with a broken callback on *this*
+	 * vnode and only if no-one else has dealt with it yet */
+	if (!mutex_trylock(&vnode->cb_broken_lock))
+		return; /* someone else is dealing with it */
=20
-			spin_unlock(&vnode->lock);
+	if (test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags)) {
+		if (afs_vnode_fetch_status(vnode) < 0)
+			goto out;
=20
-			iput(inode);
-			afs_put_server(server);
+		if (test_bit(AFS_VNODE_DELETED, &vnode->flags))
+			goto out;
=20
-			spin_lock(&server->cb_lock);
+		/* if the vnode's data version number changed then its contents
+		 * are different */
+		if (test_and_clear_bit(AFS_VNODE_ZAP_DATA, &vnode->flags)) {
+			_debug("zap data");
+			invalidate_remote_inode(&vnode->vfs_inode);
 		}
 	}
=20
-	spin_unlock(&server->cb_lock);
+out:
+	mutex_unlock(&vnode->cb_broken_lock);
=20
-	_leave(" =3D 0");
-	return 0;
+	/* avoid the potential race whereby the mutex_trylock() in this
+	 * function happens again between the clear_bit() and the
+	 * mutex_unlock() */
+	if (test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags)) {
+		_debug("requeue");
+		queue_work(afs_callback_update_worker, &vnode->cb_broken_work);
+	}
+	_leave("");
+}
+
+/*
+ * actually break a callback
+ */
+static void afs_break_callback(struct afs_server *server,
+			       struct afs_vnode *vnode)
+{
+	_enter("");
+
+	set_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
+
+	if (vnode->cb_promised) {
+		spin_lock(&vnode->lock);
+
+		_debug("break callback");
+
+		spin_lock(&server->cb_lock);
+		if (vnode->cb_promised) {
+			rb_erase(&vnode->cb_promise, &server->cb_promises);
+			vnode->cb_promised =3D false;
+		}
+		spin_unlock(&server->cb_lock);
+
+		queue_work(afs_callback_update_worker, &vnode->cb_broken_work);
+		spin_unlock(&vnode->lock);
+	}
+}
+
+/*
+ * allow the fileserver to explicitly break one callback
+ * - happens when
+ *   - the backing file is changed
+ *   - a lock is released
+ */
+static void afs_break_one_callback(struct afs_server *server,
+				   struct afs_fid *fid)
+{
+	struct afs_vnode *vnode;
+	struct rb_node *p;
+
+	_debug("find");
+	spin_lock(&server->fs_lock);
+	p =3D server->fs_vnodes.rb_node;
+	while (p) {
+		vnode =3D rb_entry(p, struct afs_vnode, server_rb);
+		if (fid->vid < vnode->fid.vid)
+			p =3D p->rb_left;
+		else if (fid->vid > vnode->fid.vid)
+			p =3D p->rb_right;
+		else if (fid->vnode < vnode->fid.vnode)
+			p =3D p->rb_left;
+		else if (fid->vnode > vnode->fid.vnode)
+			p =3D p->rb_right;
+		else if (fid->unique < vnode->fid.unique)
+			p =3D p->rb_left;
+		else if (fid->unique > vnode->fid.unique)
+			p =3D p->rb_right;
+		else
+			goto found;
+	}
+
+	/* not found so we just ignore it (it may have moved to another
+	 * server) */
+not_available:
+	_debug("not avail");
+	spin_unlock(&server->fs_lock);
+	_leave("");
+	return;
+
+found:
+	_debug("found");
+	ASSERTCMP(server, =3D=3D, vnode->server);
+
+	if (!igrab(AFS_VNODE_TO_I(vnode)))
+		goto not_available;
+	spin_unlock(&server->fs_lock);
+
+	afs_break_callback(server, vnode);
+	iput(&vnode->vfs_inode);
+	_leave("");
 }
=20
 /*
  * allow the fileserver to break callback promises
  */
-int SRXAFSCM_CallBack(struct afs_server *server, size_t count,
-		      struct afs_callback callbacks[])
+void afs_break_callbacks(struct afs_server *server, size_t count,
+			 struct afs_callback callbacks[])
 {
-	_enter("%p,%u,", server, count);
+	_enter("%p,%zu,", server, count);
=20
-	for (; count > 0; callbacks++, count--) {
-		struct afs_vnode *vnode =3D NULL;
-		struct inode *inode =3D NULL;
-		int valid =3D 0;
+	ASSERT(server !=3D NULL);
+	ASSERTCMP(count, <=3D, AFSCBMAX);
=20
+	for (; count > 0; callbacks++, count--) {
 		_debug("- Fid { vl=3D%08x n=3D%u u=3D%u }  CB { v=3D%u x=3D%u t=3D%u=
 }",
 		       callbacks->fid.vid,
 		       callbacks->fid.vnode,
@@ -101,66 +200,244 @@ int SRXAFSCM_CallBack(struct afs_server *server,=
 size_t count,
 		       callbacks->expiry,
 		       callbacks->type
 		       );
+		afs_break_one_callback(server, &callbacks->fid);
+	}
+
+	_leave("");
+	return;
+}
=20
-		/* find the inode for this fid */
-		spin_lock(&afs_cb_hash_lock);
+/*
+ * record the callback for breaking
+ * - the caller must hold server->cb_lock
+ */
+static void afs_do_give_up_callback(struct afs_server *server,
+				    struct afs_vnode *vnode)
+{
+	struct afs_callback *cb;
=20
-		list_for_each_entry(vnode,
-				    &afs_cb_hash(server, &callbacks->fid),
-				    cb_hash_link) {
-			if (memcmp(&vnode->fid, &callbacks->fid,
-				   sizeof(struct afs_fid)) !=3D 0)
-				continue;
+	_enter("%p,%p", server, vnode);
=20
-			/* right vnode, but is it same server? */
-			if (vnode->cb_server !=3D server)
-				break; /* no */
+	cb =3D &server->cb_break[server->cb_break_head];
+	cb->fid		=3D vnode->fid;
+	cb->version	=3D vnode->cb_version;
+	cb->expiry	=3D vnode->cb_expiry;
+	cb->type	=3D vnode->cb_type;
+	smp_wmb();
+	server->cb_break_head =3D
+		(server->cb_break_head + 1) &
+		(ARRAY_SIZE(server->cb_break) - 1);
=20
-			/* try and nail the inode down */
-			inode =3D igrab(AFS_VNODE_TO_I(vnode));
-			break;
+	/* defer the breaking of callbacks to try and collect as many as
+	 * possible to ship in one operation */
+	switch (atomic_inc_return(&server->cb_break_n)) {
+	case 1 ... AFSCBMAX - 1:
+		queue_delayed_work(afs_callback_update_worker,
+				   &server->cb_break_work, HZ * 2);
+		break;
+	case AFSCBMAX:
+		afs_flush_callback_breaks(server);
+		break;
+	default:
+		break;
+	}
+
+	ASSERT(server->cb_promises.rb_node !=3D NULL);
+	rb_erase(&vnode->cb_promise, &server->cb_promises);
+	vnode->cb_promised =3D false;
+	_leave("");
+}
+
+/*
+ * give up the callback registered for a vnode on the file server when=
 the
+ * inode is being cleared
+ */
+void afs_give_up_callback(struct afs_vnode *vnode)
+{
+	struct afs_server *server =3D vnode->server;
+
+	DECLARE_WAITQUEUE(myself, current);
+
+	_enter("%d", vnode->cb_promised);
+
+	_debug("GIVE UP INODE %p", &vnode->vfs_inode);
+
+	if (!vnode->cb_promised) {
+		_leave(" [not promised]");
+		return;
+	}
+
+	ASSERT(server !=3D NULL);
+
+	spin_lock(&server->cb_lock);
+	if (vnode->cb_promised && afs_breakring_space(server) =3D=3D 0) {
+		add_wait_queue(&server->cb_break_waitq, &myself);
+		for (;;) {
+			set_current_state(TASK_UNINTERRUPTIBLE);
+			if (!vnode->cb_promised ||
+			    afs_breakring_space(server) !=3D 0)
+				break;
+			spin_unlock(&server->cb_lock);
+			schedule();
+			spin_lock(&server->cb_lock);
 		}
+		remove_wait_queue(&server->cb_break_waitq, &myself);
+		__set_current_state(TASK_RUNNING);
+	}
+
+	/* of course, it's always possible for the server to break this vnode=
's
+	 * callback first... */
+	if (vnode->cb_promised)
+		afs_do_give_up_callback(server, vnode);
+
+	spin_unlock(&server->cb_lock);
+	_leave("");
+}
+
+/*
+ * dispatch a deferred give up callbacks operation
+ */
+void afs_dispatch_give_up_callbacks(struct work_struct *work)
+{
+	struct afs_server *server =3D
+		container_of(work, struct afs_server, cb_break_work.work);
+
+	_enter("");
+
+	/* tell the fileserver to discard the callback promises it has
+	 * - in the event of ENOMEM or some other error, we just forget that =
we
+	 *   had callbacks entirely, and the server will call us later to bre=
ak
+	 *   them
+	 */
+	afs_fs_give_up_callbacks(server, &afs_async_call);
+}
+
+/*
+ * flush the outstanding callback breaks on a server
+ */
+void afs_flush_callback_breaks(struct afs_server *server)
+{
+	cancel_delayed_work(&server->cb_break_work);
+	queue_delayed_work(afs_callback_update_worker,
+			   &server->cb_break_work, 0);
+}
+
+#if 0
+/*
+ * update a bunch of callbacks
+ */
+static void afs_callback_updater(struct work_struct *work)
+{
+	struct afs_server *server;
+	struct afs_vnode *vnode, *xvnode;
+	time_t now;
+	long timeout;
+	int ret;
+
+	server =3D container_of(work, struct afs_server, updater);
+
+	_enter("");
=20
-		spin_unlock(&afs_cb_hash_lock);
-
-		if (inode) {
-			/* we've found the record for this vnode */
-			spin_lock(&vnode->lock);
-			if (vnode->cb_server =3D=3D server) {
-				/* the callback _is_ on the calling server */
-				vnode->cb_server =3D NULL;
-				valid =3D 1;
-
-				afs_kafstimod_del_timer(&vnode->cb_timeout);
-				vnode->flags |=3D AFS_VNODE_CHANGED;
-
-				spin_lock(&server->cb_lock);
-				list_del_init(&vnode->cb_link);
-				spin_unlock(&server->cb_lock);
-
-				spin_lock(&afs_cb_hash_lock);
-				list_del_init(&vnode->cb_hash_link);
-				spin_unlock(&afs_cb_hash_lock);
-			}
-			spin_unlock(&vnode->lock);
-
-			if (valid) {
-				invalidate_remote_inode(inode);
-				afs_put_server(server);
-			}
-			iput(inode);
+	now =3D get_seconds();
+
+	/* find the first vnode to update */
+	spin_lock(&server->cb_lock);
+	for (;;) {
+		if (RB_EMPTY_ROOT(&server->cb_promises)) {
+			spin_unlock(&server->cb_lock);
+			_leave(" [nothing]");
+			return;
 		}
+
+		vnode =3D rb_entry(rb_first(&server->cb_promises),
+				 struct afs_vnode, cb_promise);
+		if (atomic_read(&vnode->usage) > 0)
+			break;
+		rb_erase(&vnode->cb_promise, &server->cb_promises);
+		vnode->cb_promised =3D false;
+	}
+
+	timeout =3D vnode->update_at - now;
+	if (timeout > 0) {
+		queue_delayed_work(afs_vnode_update_worker,
+				   &afs_vnode_update, timeout * HZ);
+		spin_unlock(&server->cb_lock);
+		_leave(" [nothing]");
+		return;
+	}
+
+	list_del_init(&vnode->update);
+	atomic_inc(&vnode->usage);
+	spin_unlock(&server->cb_lock);
+
+	/* we can now perform the update */
+	_debug("update %s", vnode->vldb.name);
+	vnode->state =3D AFS_VL_UPDATING;
+	vnode->upd_rej_cnt =3D 0;
+	vnode->upd_busy_cnt =3D 0;
+
+	ret =3D afs_vnode_update_record(vl, &vldb);
+	switch (ret) {
+	case 0:
+		afs_vnode_apply_update(vl, &vldb);
+		vnode->state =3D AFS_VL_UPDATING;
+		break;
+	case -ENOMEDIUM:
+		vnode->state =3D AFS_VL_VOLUME_DELETED;
+		break;
+	default:
+		vnode->state =3D AFS_VL_UNCERTAIN;
+		break;
+	}
+
+	/* and then reschedule */
+	_debug("reschedule");
+	vnode->update_at =3D get_seconds() + afs_vnode_update_timeout;
+
+	spin_lock(&server->cb_lock);
+
+	if (!list_empty(&server->cb_promises)) {
+		/* next update in 10 minutes, but wait at least 1 second more
+		 * than the newest record already queued so that we don't spam
+		 * the VL server suddenly with lots of requests
+		 */
+		xvnode =3D list_entry(server->cb_promises.prev,
+				    struct afs_vnode, update);
+		if (vnode->update_at <=3D xvnode->update_at)
+			vnode->update_at =3D xvnode->update_at + 1;
+		xvnode =3D list_entry(server->cb_promises.next,
+				    struct afs_vnode, update);
+		timeout =3D xvnode->update_at - now;
+		if (timeout < 0)
+			timeout =3D 0;
+	} else {
+		timeout =3D afs_vnode_update_timeout;
 	}
=20
-	_leave(" =3D 0");
-	return 0;
+	list_add_tail(&vnode->update, &server->cb_promises);
+
+	_debug("timeout %ld", timeout);
+	queue_delayed_work(afs_vnode_update_worker,
+			   &afs_vnode_update, timeout * HZ);
+	spin_unlock(&server->cb_lock);
+	afs_put_vnode(vl);
+}
+#endif
+
+/*
+ * initialise the callback update process
+ */
+int __init afs_callback_update_init(void)
+{
+	afs_callback_update_worker =3D
+		create_singlethread_workqueue("kafs_callbackd");
+	return afs_callback_update_worker ? 0 : -ENOMEM;
 }
=20
 /*
- * allow the fileserver to see if the cache manager is still alive
+ * shut down the callback update process
  */
-int SRXAFSCM_Probe(struct afs_server *server)
+void __exit afs_callback_update_kill(void)
 {
-	_debug("SRXAFSCM_Probe(%p)\n", server);
-	return 0;
+	destroy_workqueue(afs_callback_update_worker);
 }
diff --git a/fs/afs/cell.c b/fs/afs/cell.c
index 28ed84e..733c602 100644
--- a/fs/afs/cell.c
+++ b/fs/afs/cell.c
@@ -11,15 +11,6 @@
=20
 #include <linux/module.h>
 #include <linux/slab.h>
-#include <rxrpc/peer.h>
-#include <rxrpc/connection.h>
-#include "volume.h"
-#include "cell.h"
-#include "server.h"
-#include "transport.h"
-#include "vlclient.h"
-#include "kafstimod.h"
-#include "super.h"
 #include "internal.h"
=20
 DECLARE_RWSEM(afs_proc_cells_sem);
@@ -28,34 +19,21 @@ LIST_HEAD(afs_proc_cells);
 static struct list_head afs_cells =3D LIST_HEAD_INIT(afs_cells);
 static DEFINE_RWLOCK(afs_cells_lock);
 static DECLARE_RWSEM(afs_cells_sem); /* add/remove serialisation */
+static DECLARE_WAIT_QUEUE_HEAD(afs_cells_freeable_wq);
 static struct afs_cell *afs_cell_root;
=20
-#ifdef AFS_CACHING_SUPPORT
-static cachefs_match_val_t afs_cell_cache_match(void *target,
-						const void *entry);
-static void afs_cell_cache_update(void *source, void *entry);
-
-struct cachefs_index_def afs_cache_cell_index_def =3D {
-	.name			=3D "cell_ix",
-	.data_size		=3D sizeof(struct afs_cache_cell),
-	.keys[0]		=3D { CACHEFS_INDEX_KEYS_ASCIIZ, 64 },
-	.match			=3D afs_cell_cache_match,
-	.update			=3D afs_cell_cache_update,
-};
-#endif
-
 /*
  * create a cell record
  * - "name" is the name of the cell
  * - "vllist" is a colon separated list of IP addresses in "a.b.c.d" f=
ormat
  */
-int afs_cell_create(const char *name, char *vllist, struct afs_cell **=
_cell)
+struct afs_cell *afs_cell_create(const char *name, char *vllist)
 {
 	struct afs_cell *cell;
 	char *next;
 	int ret;
=20
-	_enter("%s", name);
+	_enter("%s,%s", name, vllist);
=20
 	BUG_ON(!name); /* TODO: want to look up "this cell" in the cache */
=20
@@ -63,27 +41,24 @@ int afs_cell_create(const char *name, char *vllist,=
 struct afs_cell **_cell)
 	cell =3D kmalloc(sizeof(struct afs_cell) + strlen(name) + 1, GFP_KERN=
EL);
 	if (!cell) {
 		_leave(" =3D -ENOMEM");
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 	}
=20
 	down_write(&afs_cells_sem);
=20
 	memset(cell, 0, sizeof(struct afs_cell));
-	atomic_set(&cell->usage, 0);
+	atomic_set(&cell->usage, 1);
=20
 	INIT_LIST_HEAD(&cell->link);
=20
-	rwlock_init(&cell->sv_lock);
-	INIT_LIST_HEAD(&cell->sv_list);
-	INIT_LIST_HEAD(&cell->sv_graveyard);
-	spin_lock_init(&cell->sv_gylock);
+	rwlock_init(&cell->servers_lock);
+	INIT_LIST_HEAD(&cell->servers);
=20
 	init_rwsem(&cell->vl_sem);
 	INIT_LIST_HEAD(&cell->vl_list);
-	INIT_LIST_HEAD(&cell->vl_graveyard);
-	spin_lock_init(&cell->vl_gylock);
+	spin_lock_init(&cell->vl_lock);
=20
-	strcpy(cell->name,name);
+	strcpy(cell->name, name);
=20
 	/* fill in the VL server list from the rest of the string */
 	ret =3D -EINVAL;
@@ -106,9 +81,9 @@ int afs_cell_create(const char *name, char *vllist, =
struct afs_cell **_cell)
 		if (cell->vl_naddrs >=3D AFS_CELL_MAX_ADDRS)
 			break;
=20
-	} while(vllist =3D next, vllist);
+	} while ((vllist =3D next));
=20
-	/* add a proc dir for this cell */
+	/* add a proc directory for this cell */
 	ret =3D afs_proc_cell_setup(cell);
 	if (ret < 0)
 		goto error;
@@ -129,30 +104,29 @@ int afs_cell_create(const char *name, char *vllis=
t, struct afs_cell **_cell)
 	down_write(&afs_proc_cells_sem);
 	list_add_tail(&cell->proc_link, &afs_proc_cells);
 	up_write(&afs_proc_cells_sem);
-
-	*_cell =3D cell;
 	up_write(&afs_cells_sem);
=20
-	_leave(" =3D 0 (%p)", cell);
-	return 0;
+	_leave(" =3D %p", cell);
+	return cell;
=20
 badaddr:
-	printk(KERN_ERR "kAFS: bad VL server IP address: '%s'\n", vllist);
+	printk(KERN_ERR "kAFS: bad VL server IP address\n");
 error:
 	up_write(&afs_cells_sem);
 	kfree(cell);
 	_leave(" =3D %d", ret);
-	return ret;
+	return ERR_PTR(ret);
 }
=20
 /*
- * initialise the cell database from module parameters
+ * set the root cell information
+ * - can be called with a module parameter string
+ * - can be called from a write to /proc/fs/afs/rootcell
  */
 int afs_cell_init(char *rootcell)
 {
 	struct afs_cell *old_root, *new_root;
 	char *cp;
-	int ret;
=20
 	_enter("");
=20
@@ -160,79 +134,60 @@ int afs_cell_init(char *rootcell)
 		/* module is loaded with no parameters, or built statically.
 		 * - in the future we might initialize cell DB here.
 		 */
-		_leave(" =3D 0 (but no root)");
+		_leave(" =3D 0 [no root]");
 		return 0;
 	}
=20
 	cp =3D strchr(rootcell, ':');
 	if (!cp) {
 		printk(KERN_ERR "kAFS: no VL server IP addresses specified\n");
-		_leave(" =3D %d (no colon)", -EINVAL);
+		_leave(" =3D -EINVAL");
 		return -EINVAL;
 	}
=20
 	/* allocate a cell record for the root cell */
 	*cp++ =3D 0;
-	ret =3D afs_cell_create(rootcell, cp, &new_root);
-	if (ret < 0) {
-		_leave(" =3D %d", ret);
-		return ret;
+	new_root =3D afs_cell_create(rootcell, cp);
+	if (IS_ERR(new_root)) {
+		_leave(" =3D %ld", PTR_ERR(new_root));
+		return PTR_ERR(new_root);
 	}
=20
-	/* as afs_put_cell() takes locks by itself, we have to do
-	 * a little gymnastics to be race-free.
-	 */
-	afs_get_cell(new_root);
-
+	/* install the new cell */
 	write_lock(&afs_cells_lock);
-	while (afs_cell_root) {
-		old_root =3D afs_cell_root;
-		afs_cell_root =3D NULL;
-		write_unlock(&afs_cells_lock);
-		afs_put_cell(old_root);
-		write_lock(&afs_cells_lock);
-	}
+	old_root =3D afs_cell_root;
 	afs_cell_root =3D new_root;
 	write_unlock(&afs_cells_lock);
+	afs_put_cell(old_root);
=20
-	_leave(" =3D %d", ret);
-	return ret;
+	_leave(" =3D 0");
+	return 0;
 }
=20
 /*
  * lookup a cell record
  */
-int afs_cell_lookup(const char *name, unsigned namesz, struct afs_cell=
 **_cell)
+struct afs_cell *afs_cell_lookup(const char *name, unsigned namesz)
 {
 	struct afs_cell *cell;
-	int ret;
=20
 	_enter("\"%*.*s\",", namesz, namesz, name ? name : "");
=20
-	*_cell =3D NULL;
+	down_read(&afs_cells_sem);
+	read_lock(&afs_cells_lock);
=20
 	if (name) {
 		/* if the cell was named, look for it in the cell record list */
-		ret =3D -ENOENT;
-		cell =3D NULL;
-		read_lock(&afs_cells_lock);
-
 		list_for_each_entry(cell, &afs_cells, link) {
 			if (strncmp(cell->name, name, namesz) =3D=3D 0) {
 				afs_get_cell(cell);
 				goto found;
 			}
 		}
-		cell =3D NULL;
+		cell =3D ERR_PTR(-ENOENT);
 	found:
-
-		read_unlock(&afs_cells_lock);
-
-		if (cell)
-			ret =3D 0;
+		;
 	} else {
-		read_lock(&afs_cells_lock);
-
 		cell =3D afs_cell_root;
 		if (!cell) {
 			/* this should not happen unless user tries to mount
@@ -241,37 +196,32 @@ int afs_cell_lookup(const char *name, unsigned na=
mesz, struct afs_cell **_cell)
 			 * ENOENT might be "more appropriate" but they happen
 			 * for other reasons.
 			 */
-			ret =3D -EDESTADDRREQ;
+			cell =3D ERR_PTR(-EDESTADDRREQ);
 		} else {
 			afs_get_cell(cell);
-			ret =3D 0;
 		}
=20
-		read_unlock(&afs_cells_lock);
 	}
=20
-	*_cell =3D cell;
-	_leave(" =3D %d (%p)", ret, cell);
-	return ret;
+	read_unlock(&afs_cells_lock);
+	up_read(&afs_cells_sem);
+	_leave(" =3D %p", cell);
+	return cell;
 }
=20
 /*
  * try and get a cell record
  */
-struct afs_cell *afs_get_cell_maybe(struct afs_cell **_cell)
+struct afs_cell *afs_get_cell_maybe(struct afs_cell *cell)
 {
-	struct afs_cell *cell;
-
 	write_lock(&afs_cells_lock);
=20
-	cell =3D *_cell;
 	if (cell && !list_empty(&cell->link))
 		afs_get_cell(cell);
 	else
 		cell =3D NULL;
=20
 	write_unlock(&afs_cells_lock);
-
 	return cell;
 }
=20
@@ -285,8 +235,7 @@ void afs_put_cell(struct afs_cell *cell)
=20
 	_enter("%p{%d,%s}", cell, atomic_read(&cell->usage), cell->name);
=20
-	/* sanity check */
-	BUG_ON(atomic_read(&cell->usage) <=3D 0);
+	ASSERTCMP(atomic_read(&cell->usage), >, 0);
=20
 	/* to prevent a race, the decrement and the dequeue must be effective=
ly
 	 * atomic */
@@ -298,35 +247,49 @@ void afs_put_cell(struct afs_cell *cell)
 		return;
 	}
=20
+	ASSERT(list_empty(&cell->servers));
+	ASSERT(list_empty(&cell->vl_list));
+
 	write_unlock(&afs_cells_lock);
=20
-	BUG_ON(!list_empty(&cell->sv_list));
-	BUG_ON(!list_empty(&cell->sv_graveyard));
-	BUG_ON(!list_empty(&cell->vl_list));
-	BUG_ON(!list_empty(&cell->vl_graveyard));
+	wake_up(&afs_cells_freeable_wq);
=20
 	_leave(" [unused]");
 }
=20
 /*
  * destroy a cell record
+ * - must be called with the afs_cells_sem write-locked
+ * - cell->link should have been broken by the caller
  */
 static void afs_cell_destroy(struct afs_cell *cell)
 {
 	_enter("%p{%d,%s}", cell, atomic_read(&cell->usage), cell->name);
=20
-	/* to prevent a race, the decrement and the dequeue must be effective=
ly
-	 * atomic */
-	write_lock(&afs_cells_lock);
+	ASSERTCMP(atomic_read(&cell->usage), >=3D, 0);
+	ASSERT(list_empty(&cell->link));
=20
-	/* sanity check */
-	BUG_ON(atomic_read(&cell->usage) !=3D 0);
+	/* wait for everyone to stop using the cell */
+	if (atomic_read(&cell->usage) > 0) {
+		DECLARE_WAITQUEUE(myself, current);
=20
-	list_del_init(&cell->link);
+		_debug("wait for cell %s", cell->name);
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		add_wait_queue(&afs_cells_freeable_wq, &myself);
=20
-	write_unlock(&afs_cells_lock);
+		while (atomic_read(&cell->usage) > 0) {
+			schedule();
+			set_current_state(TASK_UNINTERRUPTIBLE);
+		}
=20
-	down_write(&afs_cells_sem);
+		remove_wait_queue(&afs_cells_freeable_wq, &myself);
+		set_current_state(TASK_RUNNING);
+	}
+
+	_debug("cell dead");
+	ASSERTCMP(atomic_read(&cell->usage), =3D=3D, 0);
+	ASSERT(list_empty(&cell->servers));
+	ASSERT(list_empty(&cell->vl_list));
=20
 	afs_proc_cell_remove(cell);
=20
@@ -338,101 +301,25 @@ static void afs_cell_destroy(struct afs_cell *ce=
ll)
 	cachefs_relinquish_cookie(cell->cache, 0);
 #endif
=20
-	up_write(&afs_cells_sem);
-
-	BUG_ON(!list_empty(&cell->sv_list));
-	BUG_ON(!list_empty(&cell->sv_graveyard));
-	BUG_ON(!list_empty(&cell->vl_list));
-	BUG_ON(!list_empty(&cell->vl_graveyard));
-
-	/* finish cleaning up the cell */
 	kfree(cell);
=20
 	_leave(" [destroyed]");
 }
=20
 /*
- * lookup the server record corresponding to an Rx RPC peer
- */
-int afs_server_find_by_peer(const struct rxrpc_peer *peer,
-			    struct afs_server **_server)
-{
-	struct afs_server *server;
-	struct afs_cell *cell;
-
-	_enter("%p{a=3D%08x},", peer, ntohl(peer->addr.s_addr));
-
-	/* search the cell list */
-	read_lock(&afs_cells_lock);
-
-	list_for_each_entry(cell, &afs_cells, link) {
-
-		_debug("? cell %s",cell->name);
-
-		write_lock(&cell->sv_lock);
-
-		/* check the active list */
-		list_for_each_entry(server, &cell->sv_list, link) {
-			_debug("?? server %08x", ntohl(server->addr.s_addr));
-
-			if (memcmp(&server->addr, &peer->addr,
-				   sizeof(struct in_addr)) =3D=3D 0)
-				goto found_server;
-		}
-
-		/* check the inactive list */
-		spin_lock(&cell->sv_gylock);
-		list_for_each_entry(server, &cell->sv_graveyard, link) {
-			_debug("?? dead server %08x",
-			       ntohl(server->addr.s_addr));
-
-			if (memcmp(&server->addr, &peer->addr,
-				   sizeof(struct in_addr)) =3D=3D 0)
-				goto found_dead_server;
-		}
-		spin_unlock(&cell->sv_gylock);
-
-		write_unlock(&cell->sv_lock);
-	}
-	read_unlock(&afs_cells_lock);
-
-	_leave(" =3D -ENOENT");
-	return -ENOENT;
-
-	/* we found it in the graveyard - resurrect it */
-found_dead_server:
-	list_move_tail(&server->link, &cell->sv_list);
-	afs_get_server(server);
-	afs_kafstimod_del_timer(&server->timeout);
-	spin_unlock(&cell->sv_gylock);
-	goto success;
-
-	/* we found it - increment its ref count and return it */
-found_server:
-	afs_get_server(server);
-
-success:
-	write_unlock(&cell->sv_lock);
-	read_unlock(&afs_cells_lock);
-
-	*_server =3D server;
-	_leave(" =3D 0 (s=3D%p c=3D%p)", server, cell);
-	return 0;
-}
-
-/*
  * purge in-memory cell database on module unload or afs_init() failur=
e
  * - the timeout daemon is stopped before calling this
  */
 void afs_cell_purge(void)
 {
-	struct afs_vlocation *vlocation;
 	struct afs_cell *cell;
=20
 	_enter("");
=20
 	afs_put_cell(afs_cell_root);
=20
+	down_write(&afs_cells_sem);
+
 	while (!list_empty(&afs_cells)) {
 		cell =3D NULL;
=20
@@ -451,102 +338,11 @@ void afs_cell_purge(void)
 			_debug("PURGING CELL %s (%d)",
 			       cell->name, atomic_read(&cell->usage));
=20
-			BUG_ON(!list_empty(&cell->sv_list));
-			BUG_ON(!list_empty(&cell->vl_list));
-
-			/* purge the cell's VL graveyard list */
-			_debug(" - clearing VL graveyard");
-
-			spin_lock(&cell->vl_gylock);
-
-			while (!list_empty(&cell->vl_graveyard)) {
-				vlocation =3D list_entry(cell->vl_graveyard.next,
-						       struct afs_vlocation,
-						       link);
-				list_del_init(&vlocation->link);
-
-				afs_kafstimod_del_timer(&vlocation->timeout);
-
-				spin_unlock(&cell->vl_gylock);
-
-				afs_vlocation_do_timeout(vlocation);
-				/* TODO: race if move to use krxtimod instead
-				 * of kafstimod */
-
-				spin_lock(&cell->vl_gylock);
-			}
-
-			spin_unlock(&cell->vl_gylock);
-
-			/* purge the cell's server graveyard list */
-			_debug(" - clearing server graveyard");
-
-			spin_lock(&cell->sv_gylock);
-
-			while (!list_empty(&cell->sv_graveyard)) {
-				struct afs_server *server;
-
-				server =3D list_entry(cell->sv_graveyard.next,
-						    struct afs_server, link);
-				list_del_init(&server->link);
-
-				afs_kafstimod_del_timer(&server->timeout);
-
-				spin_unlock(&cell->sv_gylock);
-
-				afs_server_do_timeout(server);
-
-				spin_lock(&cell->sv_gylock);
-			}
-
-			spin_unlock(&cell->sv_gylock);
-
 			/* now the cell should be left with no references */
 			afs_cell_destroy(cell);
 		}
 	}
=20
+	up_write(&afs_cells_sem);
 	_leave("");
 }
-
-/*
- * match a cell record obtained from the cache
- */
-#ifdef AFS_CACHING_SUPPORT
-static cachefs_match_val_t afs_cell_cache_match(void *target,
-						const void *entry)
-{
-	const struct afs_cache_cell *ccell =3D entry;
-	struct afs_cell *cell =3D target;
-
-	_enter("{%s},{%s}", ccell->name, cell->name);
-
-	if (strncmp(ccell->name, cell->name, sizeof(ccell->name)) =3D=3D 0) {
-		_leave(" =3D SUCCESS");
-		return CACHEFS_MATCH_SUCCESS;
-	}
-
-	_leave(" =3D FAILED");
-	return CACHEFS_MATCH_FAILED;
-}
-#endif
-
-/*
- * update a cell record in the cache
- */
-#ifdef AFS_CACHING_SUPPORT
-static void afs_cell_cache_update(void *source, void *entry)
-{
-	struct afs_cache_cell *ccell =3D entry;
-	struct afs_cell *cell =3D source;
-
-	_enter("%p,%p", source, entry);
-
-	strncpy(ccell->name, cell->name, sizeof(ccell->name));
-
-	memcpy(ccell->vl_servers,
-	       cell->vl_addrs,
-	       min(sizeof(ccell->vl_servers), sizeof(cell->vl_addrs)));
-
-}
-#endif
diff --git a/fs/afs/cell.h b/fs/afs/cell.h
deleted file mode 100644
index c135b00..0000000
--- a/fs/afs/cell.h
+++ /dev/null
@@ -1,70 +0,0 @@
-/* AFS cell record
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef AFS_CELL_H
-#define AFS_CELL_H
-
-#include "types.h"
-#include "cache.h"
-
-#define AFS_CELL_MAX_ADDRS 15
-
-extern volatile int afs_cells_being_purged; /* T when cells are being =
purged by rmmod */
-
-/*
- * entry in the cached cell catalogue
- */
-struct afs_cache_cell {
-	char			name[64];	/* cell name (padded with NULs) */
-	struct in_addr		vl_servers[15];	/* cached cell VL servers */
-};
-
-/*
- * AFS cell record
- */
-struct afs_cell {
-	atomic_t		usage;
-	struct list_head	link;		/* main cell list link */
-	struct list_head	proc_link;	/* /proc cell list link */
-	struct proc_dir_entry	*proc_dir;	/* /proc dir for this cell */
-#ifdef AFS_CACHING_SUPPORT
-	struct cachefs_cookie	*cache;		/* caching cookie */
-#endif
-
-	/* server record management */
-	rwlock_t		sv_lock;	/* active server list lock */
-	struct list_head	sv_list;	/* active server list */
-	struct list_head	sv_graveyard;	/* inactive server list */
-	spinlock_t		sv_gylock;	/* inactive server list lock */
-
-	/* volume location record management */
-	struct rw_semaphore	vl_sem;		/* volume management serialisation semap=
hore */
-	struct list_head	vl_list;	/* cell's active VL record list */
-	struct list_head	vl_graveyard;	/* cell's inactive VL record list */
-	spinlock_t		vl_gylock;	/* graveyard lock */
-	unsigned short		vl_naddrs;	/* number of VL servers in addr list */
-	unsigned short		vl_curr_svix;	/* current server index */
-	struct in_addr		vl_addrs[AFS_CELL_MAX_ADDRS];	/* cell VL server addre=
sses */
-
-	char			name[0];	/* cell name - must go last */
-};
-
-extern int afs_cell_init(char *);
-extern int afs_cell_create(const char *, char *, struct afs_cell **);
-extern int afs_cell_lookup(const char *, unsigned, struct afs_cell **)=
;
-
-#define afs_get_cell(C) do { atomic_inc(&(C)->usage); } while(0)
-
-extern struct afs_cell *afs_get_cell_maybe(struct afs_cell **);
-extern void afs_put_cell(struct afs_cell *);
-extern void afs_cell_purge(void);
-
-#endif /* AFS_CELL_H */
diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index 3f45857..c714117 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -12,623 +12,316 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/sched.h>
-#include <linux/completion.h>
-#include "server.h"
-#include "cell.h"
-#include "transport.h"
-#include <rxrpc/rxrpc.h>
-#include <rxrpc/transport.h>
-#include <rxrpc/connection.h>
-#include <rxrpc/call.h>
-#include "cmservice.h"
+#include <linux/ip.h>
 #include "internal.h"
+#include "afs_cm.h"
=20
-static unsigned afscm_usage;		/* AFS cache manager usage count */
-static struct rw_semaphore afscm_sem;	/* AFS cache manager start/stop =
semaphore */
-
-static int afscm_new_call(struct rxrpc_call *call);
-static void afscm_attention(struct rxrpc_call *call);
-static void afscm_error(struct rxrpc_call *call);
-static void afscm_aemap(struct rxrpc_call *call);
-
-static void _SRXAFSCM_CallBack(struct rxrpc_call *call);
-static void _SRXAFSCM_InitCallBackState(struct rxrpc_call *call);
-static void _SRXAFSCM_Probe(struct rxrpc_call *call);
-
-typedef void (*_SRXAFSCM_xxxx_t)(struct rxrpc_call *call);
-
-static const struct rxrpc_operation AFSCM_ops[] =3D {
-	{
-		.id	=3D 204,
-		.asize	=3D RXRPC_APP_MARK_EOF,
-		.name	=3D "CallBack",
-		.user	=3D _SRXAFSCM_CallBack,
-	},
-	{
-		.id	=3D 205,
-		.asize	=3D RXRPC_APP_MARK_EOF,
-		.name	=3D "InitCallBackState",
-		.user	=3D _SRXAFSCM_InitCallBackState,
-	},
-	{
-		.id	=3D 206,
-		.asize	=3D RXRPC_APP_MARK_EOF,
-		.name	=3D "Probe",
-		.user	=3D _SRXAFSCM_Probe,
-	},
-#if 0
-	{
-		.id	=3D 207,
-		.asize	=3D RXRPC_APP_MARK_EOF,
-		.name	=3D "GetLock",
-		.user	=3D _SRXAFSCM_GetLock,
-	},
-	{
-		.id	=3D 208,
-		.asize	=3D RXRPC_APP_MARK_EOF,
-		.name	=3D "GetCE",
-		.user	=3D _SRXAFSCM_GetCE,
-	},
-	{
-		.id	=3D 209,
-		.asize	=3D RXRPC_APP_MARK_EOF,
-		.name	=3D "GetXStatsVersion",
-		.user	=3D _SRXAFSCM_GetXStatsVersion,
-	},
-	{
-		.id	=3D 210,
-		.asize	=3D RXRPC_APP_MARK_EOF,
-		.name	=3D "GetXStats",
-		.user	=3D _SRXAFSCM_GetXStats,
-	}
-#endif
-};
+struct workqueue_struct *afs_cm_workqueue;
=20
-static struct rxrpc_service AFSCM_service =3D {
-	.name		=3D "AFS/CM",
-	.owner		=3D THIS_MODULE,
-	.link		=3D LIST_HEAD_INIT(AFSCM_service.link),
-	.new_call	=3D afscm_new_call,
-	.service_id	=3D 1,
-	.attn_func	=3D afscm_attention,
-	.error_func	=3D afscm_error,
-	.aemap_func	=3D afscm_aemap,
-	.ops_begin	=3D &AFSCM_ops[0],
-	.ops_end	=3D &AFSCM_ops[ARRAY_SIZE(AFSCM_ops)],
-};
-
-static DECLARE_COMPLETION(kafscmd_alive);
-static DECLARE_COMPLETION(kafscmd_dead);
-static DECLARE_WAIT_QUEUE_HEAD(kafscmd_sleepq);
-static LIST_HEAD(kafscmd_attention_list);
-static LIST_HEAD(afscm_calls);
-static DEFINE_SPINLOCK(afscm_calls_lock);
-static DEFINE_SPINLOCK(kafscmd_attention_lock);
-static int kafscmd_die;
+static int afs_deliver_cb_init_call_back_state(struct afs_call *,
+					       struct sk_buff *, bool);
+static int afs_deliver_cb_probe(struct afs_call *, struct sk_buff *, b=
ool);
+static int afs_deliver_cb_callback(struct afs_call *, struct sk_buff *=
, bool);
+static void afs_cm_destructor(struct afs_call *);
=20
 /*
- * AFS Cache Manager kernel thread
+ * CB.CallBack operation type
  */
-static int kafscmd(void *arg)
-{
-	DECLARE_WAITQUEUE(myself, current);
-
-	struct rxrpc_call *call;
-	_SRXAFSCM_xxxx_t func;
-	int die;
-
-	printk(KERN_INFO "kAFS: Started kafscmd %d\n", current->pid);
-
-	daemonize("kafscmd");
-
-	complete(&kafscmd_alive);
-
-	/* loop around looking for things to attend to */
-	do {
-		if (list_empty(&kafscmd_attention_list)) {
-			set_current_state(TASK_INTERRUPTIBLE);
-			add_wait_queue(&kafscmd_sleepq, &myself);
-
-			for (;;) {
-				set_current_state(TASK_INTERRUPTIBLE);
-				if (!list_empty(&kafscmd_attention_list) ||
-				    signal_pending(current) ||
-				    kafscmd_die)
-					break;
-
-				schedule();
-			}
-
-			remove_wait_queue(&kafscmd_sleepq, &myself);
-			set_current_state(TASK_RUNNING);
-		}
-
-		die =3D kafscmd_die;
-
-		/* dequeue the next call requiring attention */
-		call =3D NULL;
-		spin_lock(&kafscmd_attention_lock);
-
-		if (!list_empty(&kafscmd_attention_list)) {
-			call =3D list_entry(kafscmd_attention_list.next,
-					  struct rxrpc_call,
-					  app_attn_link);
-			list_del_init(&call->app_attn_link);
-			die =3D 0;
-		}
-
-		spin_unlock(&kafscmd_attention_lock);
-
-		if (call) {
-			/* act upon it */
-			_debug("@@@ Begin Attend Call %p", call);
-
-			func =3D call->app_user;
-			if (func)
-				func(call);
-
-			rxrpc_put_call(call);
-
-			_debug("@@@ End Attend Call %p", call);
-		}
-
-	} while(!die);
-
-	/* and that's all */
-	complete_and_exit(&kafscmd_dead, 0);
-}
+static const struct afs_call_type afs_SRXCBCallBack =3D {
+	.deliver	=3D afs_deliver_cb_callback,
+	.abort_to_error	=3D afs_abort_to_error,
+	.destructor	=3D afs_cm_destructor,
+};
=20
 /*
- * handle a call coming in to the cache manager
- * - if I want to keep the call, I must increment its usage count
- * - the return value will be negated and passed back in an abort pack=
et if
- *   non-zero
- * - serialised by virtue of there only being one krxiod
+ * CB.InitCallBackState operation type
  */
-static int afscm_new_call(struct rxrpc_call *call)
-{
-	_enter("%p{cid=3D%u u=3D%d}",
-	       call, ntohl(call->call_id), atomic_read(&call->usage));
-
-	rxrpc_get_call(call);
-
-	/* add to my current call list */
-	spin_lock(&afscm_calls_lock);
-	list_add(&call->app_link,&afscm_calls);
-	spin_unlock(&afscm_calls_lock);
-
-	_leave(" =3D 0");
-	return 0;
-}
+static const struct afs_call_type afs_SRXCBInitCallBackState =3D {
+	.deliver	=3D afs_deliver_cb_init_call_back_state,
+	.abort_to_error	=3D afs_abort_to_error,
+	.destructor	=3D afs_cm_destructor,
+};
=20
 /*
- * queue on the kafscmd queue for attention
+ * CB.Probe operation type
  */
-static void afscm_attention(struct rxrpc_call *call)
-{
-	_enter("%p{cid=3D%u u=3D%d}",
-	       call, ntohl(call->call_id), atomic_read(&call->usage));
-
-	spin_lock(&kafscmd_attention_lock);
-
-	if (list_empty(&call->app_attn_link)) {
-		list_add_tail(&call->app_attn_link, &kafscmd_attention_list);
-		rxrpc_get_call(call);
-	}
-
-	spin_unlock(&kafscmd_attention_lock);
-
-	wake_up(&kafscmd_sleepq);
-
-	_leave(" {u=3D%d}", atomic_read(&call->usage));
-}
+static const struct afs_call_type afs_SRXCBProbe =3D {
+	.deliver	=3D afs_deliver_cb_probe,
+	.abort_to_error	=3D afs_abort_to_error,
+	.destructor	=3D afs_cm_destructor,
+};
=20
 /*
- * handle my call being aborted
- * - clean up, dequeue and put my ref to the call
+ * route an incoming cache manager call
+ * - return T if supported, F if not
  */
-static void afscm_error(struct rxrpc_call *call)
+bool afs_cm_incoming_call(struct afs_call *call)
 {
-	int removed;
-
-	_enter("%p{est=3D%s ac=3D%u er=3D%d}",
-	       call,
-	       rxrpc_call_error_states[call->app_err_state],
-	       call->app_abort_code,
-	       call->app_errno);
-
-	spin_lock(&kafscmd_attention_lock);
-
-	if (list_empty(&call->app_attn_link)) {
-		list_add_tail(&call->app_attn_link, &kafscmd_attention_list);
-		rxrpc_get_call(call);
-	}
-
-	spin_unlock(&kafscmd_attention_lock);
-
-	removed =3D 0;
-	spin_lock(&afscm_calls_lock);
-	if (!list_empty(&call->app_link)) {
-		list_del_init(&call->app_link);
-		removed =3D 1;
+	u32 operation_id =3D ntohl(call->operation_ID);
+
+	_enter("{CB.OP %u}", operation_id);
+
+	switch (operation_id) {
+	case CBCallBack:
+		call->type =3D &afs_SRXCBCallBack;
+		return true;
+	case CBInitCallBackState:
+		call->type =3D &afs_SRXCBInitCallBackState;
+		return true;
+	case CBProbe:
+		call->type =3D &afs_SRXCBProbe;
+		return true;
+	default:
+		return false;
 	}
-	spin_unlock(&afscm_calls_lock);
-
-	if (removed)
-		rxrpc_put_call(call);
-
-	wake_up(&kafscmd_sleepq);
-
-	_leave("");
 }
=20
 /*
- * map afs abort codes to/from Linux error codes
- * - called with call->lock held
+ * clean up a cache manager call
  */
-static void afscm_aemap(struct rxrpc_call *call)
+static void afs_cm_destructor(struct afs_call *call)
 {
-	switch (call->app_err_state) {
-	case RXRPC_ESTATE_LOCAL_ABORT:
-		call->app_abort_code =3D -call->app_errno;
-		break;
-	case RXRPC_ESTATE_PEER_ABORT:
-		call->app_errno =3D -ECONNABORTED;
-		break;
-	default:
-		break;
-	}
+	_enter("");
+
+	afs_put_server(call->server);
+	call->server =3D NULL;
+	kfree(call->buffer);
+	call->buffer =3D NULL;
 }
=20
 /*
- * start the cache manager service if not already started
+ * allow the fileserver to see if the cache manager is still alive
  */
-int afscm_start(void)
+static void SRXAFSCB_CallBack(struct work_struct *work)
 {
-	int ret;
-
-	down_write(&afscm_sem);
-	if (!afscm_usage) {
-		ret =3D kernel_thread(kafscmd, NULL, 0);
-		if (ret < 0)
-			goto out;
-
-		wait_for_completion(&kafscmd_alive);
-
-		ret =3D rxrpc_add_service(afs_transport, &AFSCM_service);
-		if (ret < 0)
-			goto kill;
+	struct afs_call *call =3D container_of(work, struct afs_call, work);
=20
-		afs_kafstimod_add_timer(&afs_mntpt_expiry_timer,
-					afs_mntpt_expiry_timeout * HZ);
-	}
-
-	afscm_usage++;
-	up_write(&afscm_sem);
-
-	return 0;
+	_enter("");
=20
-kill:
-	kafscmd_die =3D 1;
-	wake_up(&kafscmd_sleepq);
-	wait_for_completion(&kafscmd_dead);
+	/* be sure to send the reply *before* attempting to spam the AFS serv=
er
+	 * with FSFetchStatus requests on the vnodes with broken callbacks le=
st
+	 * the AFS server get into a vicious cycle of trying to break further
+	 * callbacks because it hadn't received completion of the CBCallBack =
op
+	 * yet */
+	afs_send_empty_reply(call);
=20
-out:
-	up_write(&afscm_sem);
-	return ret;
+	afs_break_callbacks(call->server, call->count, call->request);
+	_leave("");
 }
=20
 /*
- * stop the cache manager service
+ * deliver request data to a CB.CallBack call
  */
-void afscm_stop(void)
+static int afs_deliver_cb_callback(struct afs_call *call, struct sk_bu=
ff *skb,
+				   bool last)
 {
-	struct rxrpc_call *call;
-
-	down_write(&afscm_sem);
-
-	BUG_ON(afscm_usage =3D=3D 0);
-	afscm_usage--;
-
-	if (afscm_usage =3D=3D 0) {
-		/* don't want more incoming calls */
-		rxrpc_del_service(afs_transport, &AFSCM_service);
-
-		/* abort any calls I've still got open (the afscm_error() will
-		 * dequeue them) */
-		spin_lock(&afscm_calls_lock);
-		while (!list_empty(&afscm_calls)) {
-			call =3D list_entry(afscm_calls.next,
-					  struct rxrpc_call,
-					  app_link);
-
-			list_del_init(&call->app_link);
-			rxrpc_get_call(call);
-			spin_unlock(&afscm_calls_lock);
-
-			rxrpc_call_abort(call, -ESRCH); /* abort, dequeue and
-							 * put */
-
-			_debug("nuking active call %08x.%d",
-			       ntohl(call->conn->conn_id),
-			       ntohl(call->call_id));
-			rxrpc_put_call(call);
-			rxrpc_put_call(call);
-
-			spin_lock(&afscm_calls_lock);
+	struct afs_callback *cb;
+	struct afs_server *server;
+	struct in_addr addr;
+	__be32 *bp;
+	u32 tmp;
+	int ret, loop;
+
+	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+
+	switch (call->unmarshall) {
+	case 0:
+		call->offset =3D 0;
+		call->unmarshall++;
+
+		/* extract the FID array and its count in two steps */
+	case 1:
+		_debug("extract FID count");
+		ret =3D afs_extract_data(call, skb, last, &call->tmp, 4);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
 		}
-		spin_unlock(&afscm_calls_lock);
-
-		/* get rid of my daemon */
-		kafscmd_die =3D 1;
-		wake_up(&kafscmd_sleepq);
-		wait_for_completion(&kafscmd_dead);
-
-		/* dispose of any calls waiting for attention */
-		spin_lock(&kafscmd_attention_lock);
-		while (!list_empty(&kafscmd_attention_list)) {
-			call =3D list_entry(kafscmd_attention_list.next,
-					  struct rxrpc_call,
-					  app_attn_link);
-
-			list_del_init(&call->app_attn_link);
-			spin_unlock(&kafscmd_attention_lock);
=20
-			rxrpc_put_call(call);
-
-			spin_lock(&kafscmd_attention_lock);
+		call->count =3D ntohl(call->tmp);
+		_debug("FID count: %u", call->count);
+		if (call->count > AFSCBMAX)
+			return -EBADMSG;
+
+		call->buffer =3D kmalloc(call->count * 3 * 4, GFP_KERNEL);
+		if (!call->buffer)
+			return -ENOMEM;
+		call->offset =3D 0;
+		call->unmarshall++;
+
+	case 2:
+		_debug("extract FID array");
+		ret =3D afs_extract_data(call, skb, last, call->buffer,
+				       call->count * 3 * 4);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
 		}
-		spin_unlock(&kafscmd_attention_lock);
-
-		afs_kafstimod_del_timer(&afs_mntpt_expiry_timer);
-	}
-
-	up_write(&afscm_sem);
-}
=20
-/*
- * handle the fileserver breaking a set of callbacks
- */
-static void _SRXAFSCM_CallBack(struct rxrpc_call *call)
-{
-	struct afs_server *server;
-	size_t count, qty, tmp;
-	int ret =3D 0, removed;
-
-	_enter("%p{acs=3D%s}", call, rxrpc_call_states[call->app_call_state])=
;
-
-	server =3D afs_server_get_from_peer(call->conn->peer);
-
-	switch (call->app_call_state) {
-		/* we've received the last packet
-		 * - drain all the data from the call and send the reply
-		 */
-	case RXRPC_CSTATE_SRVR_GOT_ARGS:
-		ret =3D -EBADMSG;
-		qty =3D call->app_ready_qty;
-		if (qty < 8 || qty > 50 * (6 * 4) + 8)
-			break;
-
-		{
-			struct afs_callback *cb, *pcb;
-			int loop;
-			__be32 *fp, *bp;
-
-			fp =3D rxrpc_call_alloc_scratch(call, qty);
-
-			/* drag the entire argument block out to the scratch
-			 * space */
-			ret =3D rxrpc_call_read_data(call, fp, qty, 0);
-			if (ret < 0)
-				break;
-
-			/* and unmarshall the parameter block */
-			ret =3D -EBADMSG;
-			count =3D ntohl(*fp++);
-			if (count>AFSCBMAX ||
-			    (count * (3 * 4) + 8 !=3D qty &&
-			     count * (6 * 4) + 8 !=3D qty))
-				break;
-
-			bp =3D fp + count*3;
-			tmp =3D ntohl(*bp++);
-			if (tmp > 0 && tmp !=3D count)
-				break;
-			if (tmp =3D=3D 0)
-				bp =3D NULL;
-
-			pcb =3D cb =3D rxrpc_call_alloc_scratch_s(
-				call, struct afs_callback);
-
-			for (loop =3D count - 1; loop >=3D 0; loop--) {
-				pcb->fid.vid	=3D ntohl(*fp++);
-				pcb->fid.vnode	=3D ntohl(*fp++);
-				pcb->fid.unique	=3D ntohl(*fp++);
-				if (bp) {
-					pcb->version	=3D ntohl(*bp++);
-					pcb->expiry	=3D ntohl(*bp++);
-					pcb->type	=3D ntohl(*bp++);
-				} else {
-					pcb->version	=3D 0;
-					pcb->expiry	=3D 0;
-					pcb->type	=3D AFSCM_CB_UNTYPED;
-				}
-				pcb++;
-			}
-
-			/* invoke the actual service routine */
-			ret =3D SRXAFSCM_CallBack(server, count, cb);
-			if (ret < 0)
-				break;
+		_debug("unmarshall FID array");
+		call->request =3D kcalloc(call->count,
+					sizeof(struct afs_callback),
+					GFP_KERNEL);
+		if (!call->request)
+			return -ENOMEM;
+
+		cb =3D call->request;
+		bp =3D call->buffer;
+		for (loop =3D call->count; loop > 0; loop--, cb++) {
+			cb->fid.vid	=3D ntohl(*bp++);
+			cb->fid.vnode	=3D ntohl(*bp++);
+			cb->fid.unique	=3D ntohl(*bp++);
+			cb->type	=3D AFSCM_CB_UNTYPED;
 		}
=20
-		/* send the reply */
-		ret =3D rxrpc_call_write_data(call, 0, NULL, RXRPC_LAST_PACKET,
-					    GFP_KERNEL, 0, &count);
-		if (ret < 0)
-			break;
-		break;
+		call->offset =3D 0;
+		call->unmarshall++;
+
+		/* extract the callback array and its count in two steps */
+	case 3:
+		_debug("extract CB count");
+		ret =3D afs_extract_data(call, skb, last, &call->tmp, 4);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
+		}
=20
-		/* operation complete */
-	case RXRPC_CSTATE_COMPLETE:
-		call->app_user =3D NULL;
-		removed =3D 0;
-		spin_lock(&afscm_calls_lock);
-		if (!list_empty(&call->app_link)) {
-			list_del_init(&call->app_link);
-			removed =3D 1;
+		tmp =3D ntohl(call->tmp);
+		_debug("CB count: %u", tmp);
+		if (tmp !=3D call->count && tmp !=3D 0)
+			return -EBADMSG;
+		call->offset =3D 0;
+		call->unmarshall++;
+		if (tmp =3D=3D 0)
+			goto empty_cb_array;
+
+	case 4:
+		_debug("extract CB array");
+		ret =3D afs_extract_data(call, skb, last, call->request,
+				       call->count * 3 * 4);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
 		}
-		spin_unlock(&afscm_calls_lock);
=20
-		if (removed)
-			rxrpc_put_call(call);
-		break;
+		_debug("unmarshall CB array");
+		cb =3D call->request;
+		bp =3D call->buffer;
+		for (loop =3D call->count; loop > 0; loop--, cb++) {
+			cb->version	=3D ntohl(*bp++);
+			cb->expiry	=3D ntohl(*bp++);
+			cb->type	=3D ntohl(*bp++);
+		}
=20
-		/* operation terminated on error */
-	case RXRPC_CSTATE_ERROR:
-		call->app_user =3D NULL;
-		break;
+	empty_cb_array:
+		call->offset =3D 0;
+		call->unmarshall++;
=20
-	default:
+	case 5:
+		_debug("trailer");
+		if (skb->len !=3D 0)
+			return -EBADMSG;
 		break;
 	}
=20
-	if (ret < 0)
-		rxrpc_call_abort(call, ret);
+	if (!last)
+		return 0;
=20
-	afs_put_server(server);
+	call->state =3D AFS_CALL_REPLYING;
=20
-	_leave(" =3D %d", ret);
+	/* we'll need the file server record as that tells us which set of
+	 * vnodes to operate upon */
+	memcpy(&addr, &ip_hdr(skb)->saddr, 4);
+	server =3D afs_find_server(&addr);
+	if (!server)
+		return -ENOTCONN;
+	call->server =3D server;
+
+	INIT_WORK(&call->work, SRXAFSCB_CallBack);
+	schedule_work(&call->work);
+	return 0;
 }
=20
 /*
- * handle the fileserver asking us to initialise our callback state
+ * allow the fileserver to request callback state (re-)initialisation
  */
-static void _SRXAFSCM_InitCallBackState(struct rxrpc_call *call)
+static void SRXAFSCB_InitCallBackState(struct work_struct *work)
 {
-	struct afs_server *server;
-	size_t count;
-	int ret =3D 0, removed;
-
-	_enter("%p{acs=3D%s}", call, rxrpc_call_states[call->app_call_state])=
;
-
-	server =3D afs_server_get_from_peer(call->conn->peer);
-
-	switch (call->app_call_state) {
-		/* we've received the last packet - drain all the data from the
-		 * call */
-	case RXRPC_CSTATE_SRVR_GOT_ARGS:
-		/* shouldn't be any args */
-		ret =3D -EBADMSG;
-		break;
+	struct afs_call *call =3D container_of(work, struct afs_call, work);
=20
-		/* send the reply when asked for it */
-	case RXRPC_CSTATE_SRVR_SND_REPLY:
-		/* invoke the actual service routine */
-		ret =3D SRXAFSCM_InitCallBackState(server);
-		if (ret < 0)
-			break;
-
-		ret =3D rxrpc_call_write_data(call, 0, NULL, RXRPC_LAST_PACKET,
-					    GFP_KERNEL, 0, &count);
-		if (ret < 0)
-			break;
-		break;
+	_enter("{%p}", call->server);
=20
-		/* operation complete */
-	case RXRPC_CSTATE_COMPLETE:
-		call->app_user =3D NULL;
-		removed =3D 0;
-		spin_lock(&afscm_calls_lock);
-		if (!list_empty(&call->app_link)) {
-			list_del_init(&call->app_link);
-			removed =3D 1;
-		}
-		spin_unlock(&afscm_calls_lock);
-
-		if (removed)
-			rxrpc_put_call(call);
-		break;
-
-		/* operation terminated on error */
-	case RXRPC_CSTATE_ERROR:
-		call->app_user =3D NULL;
-		break;
-
-	default:
-		break;
-	}
-
-	if (ret < 0)
-		rxrpc_call_abort(call, ret);
-
-	afs_put_server(server);
-
-	_leave(" =3D %d", ret);
+	afs_init_callback_state(call->server);
+	afs_send_empty_reply(call);
+	_leave("");
 }
=20
 /*
- * handle a probe from a fileserver
+ * deliver request data to a CB.InitCallBackState call
  */
-static void _SRXAFSCM_Probe(struct rxrpc_call *call)
+static int afs_deliver_cb_init_call_back_state(struct afs_call *call,
+					       struct sk_buff *skb,
+					       bool last)
 {
 	struct afs_server *server;
-	size_t count;
-	int ret =3D 0, removed;
+	struct in_addr addr;
=20
-	_enter("%p{acs=3D%s}", call, rxrpc_call_states[call->app_call_state])=
;
+	_enter(",{%u},%d", skb->len, last);
=20
-	server =3D afs_server_get_from_peer(call->conn->peer);
+	if (skb->len > 0)
+		return -EBADMSG;
+	if (!last)
+		return 0;
=20
-	switch (call->app_call_state) {
-		/* we've received the last packet - drain all the data from the
-		 * call */
-	case RXRPC_CSTATE_SRVR_GOT_ARGS:
-		/* shouldn't be any args */
-		ret =3D -EBADMSG;
-		break;
+	/* no unmarshalling required */
+	call->state =3D AFS_CALL_REPLYING;
=20
-		/* send the reply when asked for it */
-	case RXRPC_CSTATE_SRVR_SND_REPLY:
-		/* invoke the actual service routine */
-		ret =3D SRXAFSCM_Probe(server);
-		if (ret < 0)
-			break;
-
-		ret =3D rxrpc_call_write_data(call, 0, NULL, RXRPC_LAST_PACKET,
-					    GFP_KERNEL, 0, &count);
-		if (ret < 0)
-			break;
-		break;
+	/* we'll need the file server record as that tells us which set of
+	 * vnodes to operate upon */
+	memcpy(&addr, &ip_hdr(skb)->saddr, 4);
+	server =3D afs_find_server(&addr);
+	if (!server)
+		return -ENOTCONN;
+	call->server =3D server;
=20
-		/* operation complete */
-	case RXRPC_CSTATE_COMPLETE:
-		call->app_user =3D NULL;
-		removed =3D 0;
-		spin_lock(&afscm_calls_lock);
-		if (!list_empty(&call->app_link)) {
-			list_del_init(&call->app_link);
-			removed =3D 1;
-		}
-		spin_unlock(&afscm_calls_lock);
+	INIT_WORK(&call->work, SRXAFSCB_InitCallBackState);
+	schedule_work(&call->work);
+	return 0;
+}
=20
-		if (removed)
-			rxrpc_put_call(call);
-		break;
+/*
+ * allow the fileserver to see if the cache manager is still alive
+ */
+static void SRXAFSCB_Probe(struct work_struct *work)
+{
+	struct afs_call *call =3D container_of(work, struct afs_call, work);
=20
-		/* operation terminated on error */
-	case RXRPC_CSTATE_ERROR:
-		call->app_user =3D NULL;
-		break;
+	_enter("");
+	afs_send_empty_reply(call);
+	_leave("");
+}
=20
-	default:
-		break;
-	}
+/*
+ * deliver request data to a CB.Probe call
+ */
+static int afs_deliver_cb_probe(struct afs_call *call, struct sk_buff =
*skb,
+				bool last)
+{
+	_enter(",{%u},%d", skb->len, last);
=20
-	if (ret < 0)
-		rxrpc_call_abort(call, ret);
+	if (skb->len > 0)
+		return -EBADMSG;
+	if (!last)
+		return 0;
=20
-	afs_put_server(server);
+	/* no unmarshalling required */
+	call->state =3D AFS_CALL_REPLYING;
=20
-	_leave(" =3D %d", ret);
+	INIT_WORK(&call->work, SRXAFSCB_Probe);
+	schedule_work(&call->work);
+	return 0;
 }
diff --git a/fs/afs/cmservice.h b/fs/afs/cmservice.h
deleted file mode 100644
index 66e10c1..0000000
--- a/fs/afs/cmservice.h
+++ /dev/null
@@ -1,28 +0,0 @@
-/* AFS Cache Manager Service declarations
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef AFS_CMSERVICE_H
-#define AFS_CMSERVICE_H
-
-#include <rxrpc/transport.h>
-#include "types.h"
-
-/* cache manager start/stop */
-extern int afscm_start(void);
-extern void afscm_stop(void);
-
-/* cache manager server functions */
-extern int SRXAFSCM_InitCallBackState(struct afs_server *);
-extern int SRXAFSCM_CallBack(struct afs_server *, size_t,
-			     struct afs_callback[]);
-extern int SRXAFSCM_Probe(struct afs_server *);
-
-#endif /* AFS_CMSERVICE_H */
diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index 2f6d923..d7697f6 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -15,11 +15,6 @@
 #include <linux/slab.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
-#include <linux/smp_lock.h>
-#include "vnode.h"
-#include "volume.h"
-#include <rxrpc/call.h>
-#include "super.h"
 #include "internal.h"
=20
 static struct dentry *afs_dir_lookup(struct inode *dir, struct dentry =
*dentry,
@@ -127,9 +122,10 @@ static inline void afs_dir_check_page(struct inode=
 *dir, struct page *page)
 	if (qty =3D=3D 0)
 		goto error;
=20
-	if (page->index=3D=3D0 && qty!=3Dntohs(dbuf->blocks[0].pagehdr.npages=
)) {
+	if (page->index =3D=3D 0 && qty !=3D ntohs(dbuf->blocks[0].pagehdr.np=
ages)) {
 		printk("kAFS: %s(%lu): wrong number of dir blocks %d!=3D%hu\n",
-		       __FUNCTION__,dir->i_ino,qty,ntohs(dbuf->blocks[0].pagehdr.npa=
ges));
+		       __FUNCTION__, dir->i_ino, qty,
+		       ntohs(dbuf->blocks[0].pagehdr.npages));
 		goto error;
 	}
 #endif
@@ -194,6 +190,7 @@ static struct page *afs_dir_get_page(struct inode *=
dir, unsigned long index)
=20
 fail:
 	afs_dir_put_page(page);
+	_leave(" =3D -EIO");
 	return ERR_PTR(-EIO);
 }
=20
@@ -207,7 +204,7 @@ static int afs_dir_open(struct inode *inode, struct=
 file *file)
 	BUILD_BUG_ON(sizeof(union afs_dir_block) !=3D 2048);
 	BUILD_BUG_ON(sizeof(union afs_dirent) !=3D 32);
=20
-	if (AFS_FS_I(inode)->flags & AFS_VNODE_DELETED)
+	if (test_bit(AFS_VNODE_DELETED, &AFS_FS_I(inode)->flags))
 		return -ENOENT;
=20
 	_leave(" =3D 0");
@@ -242,7 +239,7 @@ static int afs_dir_iterate_block(unsigned *fpos,
 		/* skip entries marked unused in the bitmap */
 		if (!(block->pagehdr.bitmap[offset / 8] &
 		      (1 << (offset % 8)))) {
-			_debug("ENT[%Zu.%u]: unused\n",
+			_debug("ENT[%Zu.%u]: unused",
 			       blkoff / sizeof(union afs_dir_block), offset);
 			if (offset >=3D curr)
 				*fpos =3D blkoff +
@@ -256,7 +253,7 @@ static int afs_dir_iterate_block(unsigned *fpos,
 			       sizeof(*block) -
 			       offset * sizeof(union afs_dirent));
=20
-		_debug("ENT[%Zu.%u]: %s %Zu \"%s\"\n",
+		_debug("ENT[%Zu.%u]: %s %Zu \"%s\"",
 		       blkoff / sizeof(union afs_dir_block), offset,
 		       (offset < curr ? "skip" : "fill"),
 		       nlen, dire->u.name);
@@ -266,7 +263,7 @@ static int afs_dir_iterate_block(unsigned *fpos,
 			if (next >=3D AFS_DIRENT_PER_BLOCK) {
 				_debug("ENT[%Zu.%u]:"
 				       " %u travelled beyond end dir block"
-				       " (len %u/%Zu)\n",
+				       " (len %u/%Zu)",
 				       blkoff / sizeof(union afs_dir_block),
 				       offset, next, tmp, nlen);
 				return -EIO;
@@ -274,13 +271,13 @@ static int afs_dir_iterate_block(unsigned *fpos,
 			if (!(block->pagehdr.bitmap[next / 8] &
 			      (1 << (next % 8)))) {
 				_debug("ENT[%Zu.%u]:"
-				       " %u unmarked extension (len %u/%Zu)\n",
+				       " %u unmarked extension (len %u/%Zu)",
 				       blkoff / sizeof(union afs_dir_block),
 				       offset, next, tmp, nlen);
 				return -EIO;
 			}
=20
-			_debug("ENT[%Zu.%u]: ext %u/%Zu\n",
+			_debug("ENT[%Zu.%u]: ext %u/%Zu",
 			       blkoff / sizeof(union afs_dir_block),
 			       next, tmp, nlen);
 			next++;
@@ -311,12 +308,12 @@ static int afs_dir_iterate_block(unsigned *fpos,
 }
=20
 /*
- * read an AFS directory
+ * iterate through the data blob that lists the contents of an AFS dir=
ectory
  */
 static int afs_dir_iterate(struct inode *dir, unsigned *fpos, void *co=
okie,
 			   filldir_t filldir)
 {
-	union afs_dir_block	*dblock;
+	union afs_dir_block *dblock;
 	struct afs_dir_page *dbuf;
 	struct page *page;
 	unsigned blkoff, limit;
@@ -324,7 +321,7 @@ static int afs_dir_iterate(struct inode *dir, unsig=
ned *fpos, void *cookie,
=20
 	_enter("{%lu},%u,,", dir->i_ino, *fpos);
=20
-	if (AFS_FS_I(dir)->flags & AFS_VNODE_DELETED) {
+	if (test_bit(AFS_VNODE_DELETED, &AFS_FS_I(dir)->flags)) {
 		_leave(" =3D -ESTALE");
 		return -ESTALE;
 	}
@@ -381,10 +378,12 @@ static int afs_dir_readdir(struct file *file, voi=
d *cookie, filldir_t filldir)
 	unsigned fpos;
 	int ret;
=20
-	_enter("{%Ld,{%lu}}", file->f_pos, file->f_path.dentry->d_inode->i_in=
o);
+	_enter("{%Ld,{%lu}}",
+	       file->f_pos, file->f_path.dentry->d_inode->i_ino);
=20
 	fpos =3D file->f_pos;
-	ret =3D afs_dir_iterate(file->f_path.dentry->d_inode, &fpos, cookie, =
filldir);
+	ret =3D afs_dir_iterate(file->f_path.dentry->d_inode, &fpos,
+			      cookie, filldir);
 	file->f_pos =3D fpos;
=20
 	_leave(" =3D %d", ret);
@@ -401,9 +400,13 @@ static int afs_dir_lookup_filldir(void *_cookie, c=
onst char *name, int nlen,
 {
 	struct afs_dir_lookup_cookie *cookie =3D _cookie;
=20
-	_enter("{%s,%Zu},%s,%u,,%lu,%u",
+	_enter("{%s,%Zu},%s,%u,,%llu,%u",
 	       cookie->name, cookie->nlen, name, nlen, ino, dtype);
=20
+	/* insanity checks first */
+	BUILD_BUG_ON(sizeof(union afs_dir_block) !=3D 2048);
+	BUILD_BUG_ON(sizeof(union afs_dirent) !=3D 32);
+
 	if (cookie->nlen !=3D nlen || memcmp(cookie->name, name, nlen) !=3D 0=
) {
 		_leave(" =3D 0 [no]");
 		return 0;
@@ -418,34 +421,17 @@ static int afs_dir_lookup_filldir(void *_cookie, =
const char *name, int nlen,
 }
=20
 /*
- * look up an entry in a directory
+ * do a lookup in a directory
  */
-static struct dentry *afs_dir_lookup(struct inode *dir, struct dentry =
*dentry,
-				     struct nameidata *nd)
+static int afs_do_lookup(struct inode *dir, struct dentry *dentry,
+			 struct afs_fid *fid)
 {
 	struct afs_dir_lookup_cookie cookie;
 	struct afs_super_info *as;
-	struct afs_vnode *vnode;
-	struct inode *inode;
 	unsigned fpos;
 	int ret;
=20
-	_enter("{%lu},%p{%s}", dir->i_ino, dentry, dentry->d_name.name);
-
-	/* insanity checks first */
-	BUILD_BUG_ON(sizeof(union afs_dir_block) !=3D 2048);
-	BUILD_BUG_ON(sizeof(union afs_dirent) !=3D 32);
-
-	if (dentry->d_name.len > 255) {
-		_leave(" =3D -ENAMETOOLONG");
-		return ERR_PTR(-ENAMETOOLONG);
-	}
-
-	vnode =3D AFS_FS_I(dir);
-	if (vnode->flags & AFS_VNODE_DELETED) {
-		_leave(" =3D -ESTALE");
-		return ERR_PTR(-ESTALE);
-	}
+	_enter("{%lu},%p{%s},", dir->i_ino, dentry, dentry->d_name.name);
=20
 	as =3D dir->i_sb->s_fs_info;
=20
@@ -458,30 +444,64 @@ static struct dentry *afs_dir_lookup(struct inode=
 *dir, struct dentry *dentry,
 	fpos =3D 0;
 	ret =3D afs_dir_iterate(dir, &fpos, &cookie, afs_dir_lookup_filldir);
 	if (ret < 0) {
-		_leave(" =3D %d", ret);
-		return ERR_PTR(ret);
+		_leave(" =3D %d [iter]", ret);
+		return ret;
 	}
=20
 	ret =3D -ENOENT;
 	if (!cookie.found) {
-		_leave(" =3D %d", ret);
-		return ERR_PTR(ret);
+		_leave(" =3D -ENOENT [not found]");
+		return -ENOENT;
 	}
=20
-	/* instantiate the dentry */
-	ret =3D afs_iget(dir->i_sb, &cookie.fid, &inode);
+	*fid =3D cookie.fid;
+	_leave(" =3D 0 { vn=3D%u u=3D%u }", fid->vnode, fid->unique);
+	return 0;
+}
+
+/*
+ * look up an entry in a directory
+ */
+static struct dentry *afs_dir_lookup(struct inode *dir, struct dentry =
*dentry,
+				     struct nameidata *nd)
+{
+	struct afs_vnode *vnode;
+	struct afs_fid fid;
+	struct inode *inode;
+	int ret;
+
+	_enter("{%lu},%p{%s}", dir->i_ino, dentry, dentry->d_name.name);
+
+	if (dentry->d_name.len > 255) {
+		_leave(" =3D -ENAMETOOLONG");
+		return ERR_PTR(-ENAMETOOLONG);
+	}
+
+	vnode =3D AFS_FS_I(dir);
+	if (test_bit(AFS_VNODE_DELETED, &vnode->flags)) {
+		_leave(" =3D -ESTALE");
+		return ERR_PTR(-ESTALE);
+	}
+
+	ret =3D afs_do_lookup(dir, dentry, &fid);
 	if (ret < 0) {
-		_leave(" =3D %d", ret);
+		_leave(" =3D %d [do]", ret);
 		return ERR_PTR(ret);
 	}
=20
+	/* instantiate the dentry */
+	inode =3D afs_iget(dir->i_sb, &fid);
+	if (IS_ERR(inode)) {
+		_leave(" =3D %ld", PTR_ERR(inode));
+		return ERR_PTR(PTR_ERR(inode));
+	}
+
 	dentry->d_op =3D &afs_fs_dentry_operations;
-	dentry->d_fsdata =3D (void *) (unsigned long) vnode->status.version;
=20
 	d_add(dentry, inode);
 	_leave(" =3D 0 { vn=3D%u u=3D%u } -> { ino=3D%lu v=3D%lu }",
-	       cookie.fid.vnode,
-	       cookie.fid.unique,
+	       fid.vnode,
+	       fid.unique,
 	       dentry->d_inode->i_ino,
 	       dentry->d_inode->i_version);
=20
@@ -489,23 +509,65 @@ static struct dentry *afs_dir_lookup(struct inode=
 *dir, struct dentry *dentry,
 }
=20
 /*
+ * propagate changed and modified flags on a directory to all the chil=
dren of
+ * that directory as they may indicate that the ACL on the dir has cha=
nged,
+ * potentially rendering the child inaccessible or that a file has bee=
n deleted
+ * or renamed
+ */
+static void afs_propagate_dir_changes(struct dentry *dir)
+{
+	struct dentry *child;
+	bool c, m;
+
+	c =3D test_bit(AFS_VNODE_CHANGED, &AFS_FS_I(dir->d_inode)->flags);
+	m =3D test_bit(AFS_VNODE_MODIFIED, &AFS_FS_I(dir->d_inode)->flags);
+
+	_enter("{%d,%d}", c, m);
+
+	spin_lock(&dir->d_lock);
+
+	list_for_each_entry(child, &dir->d_subdirs, d_u.d_child) {
+		if (child->d_inode) {
+			struct afs_vnode *vnode;
+
+			_debug("tag %s", child->d_name.name);
+			vnode =3D AFS_FS_I(child->d_inode);
+			if (c)
+				set_bit(AFS_VNODE_DIR_CHANGED, &vnode->flags);
+			if (m)
+				set_bit(AFS_VNODE_DIR_MODIFIED, &vnode->flags);
+		}
+	}
+
+	spin_unlock(&dir->d_lock);
+}
+
+/*
  * check that a dentry lookup hit has found a valid entry
  * - NOTE! the hit can be a negative hit too, so we can't assume we ha=
ve an
  *   inode
- * (derived from nfs_lookup_revalidate)
+ * - there are several things we need to check
+ *   - parent dir data changes (rm, rmdir, rename, mkdir, create, link=
,
+ *     symlink)
+ *   - parent dir metadata changed (security changes)
+ *   - dentry data changed (write, truncate)
+ *   - dentry metadata changed (security changes)
  */
 static int afs_d_revalidate(struct dentry *dentry, struct nameidata *n=
d)
 {
-	struct afs_dir_lookup_cookie cookie;
+	struct afs_vnode *vnode;
+	struct afs_fid fid;
 	struct dentry *parent;
 	struct inode *inode, *dir;
-	unsigned fpos;
 	int ret;
=20
-	_enter("{sb=3D%p n=3D%s},", dentry->d_sb, dentry->d_name.name);
+	vnode =3D AFS_FS_I(dentry->d_inode);
+
+	_enter("{sb=3D%p n=3D%s fl=3D%lx},",
+	       dentry->d_sb, dentry->d_name.name, vnode->flags);
=20
 	/* lock down the parent dentry so we can peer at it */
-	parent =3D dget_parent(dentry->d_parent);
+	parent =3D dget_parent(dentry);
=20
 	dir =3D parent->d_inode;
 	inode =3D dentry->d_inode;
@@ -517,81 +579,92 @@ static int afs_d_revalidate(struct dentry *dentry=
, struct nameidata *nd)
 	/* handle a bad inode */
 	if (is_bad_inode(inode)) {
 		printk("kAFS: afs_d_revalidate: %s/%s has bad inode\n",
-		       dentry->d_parent->d_name.name, dentry->d_name.name);
+		       parent->d_name.name, dentry->d_name.name);
 		goto out_bad;
 	}
=20
-	/* force a full look up if the parent directory changed since last th=
e
-	 * server was consulted
-	 * - otherwise this inode must still exist, even if the inode details
-	 *   themselves have changed
-	 */
-	if (AFS_FS_I(dir)->flags & AFS_VNODE_CHANGED)
-		afs_vnode_fetch_status(AFS_FS_I(dir));
-
-	if (AFS_FS_I(dir)->flags & AFS_VNODE_DELETED) {
+	/* check that this dirent still exists if the directory's contents we=
re
+	 * modified */
+	if (test_bit(AFS_VNODE_DELETED, &AFS_FS_I(dir)->flags)) {
 		_debug("%s: parent dir deleted", dentry->d_name.name);
 		goto out_bad;
 	}
=20
-	if (AFS_FS_I(inode)->flags & AFS_VNODE_DELETED) {
-		_debug("%s: file already deleted", dentry->d_name.name);
-		goto out_bad;
-	}
-
-	if ((unsigned long) dentry->d_fsdata !=3D
-	    (unsigned long) AFS_FS_I(dir)->status.version) {
-		_debug("%s: parent changed %lu -> %u",
-		       dentry->d_name.name,
-		       (unsigned long) dentry->d_fsdata,
-		       (unsigned) AFS_FS_I(dir)->status.version);
+	if (test_and_clear_bit(AFS_VNODE_DIR_MODIFIED, &vnode->flags)) {
+		/* rm/rmdir/rename may have occurred */
+		_debug("dir modified");
=20
 		/* search the directory for this vnode */
-		cookie.name	=3D dentry->d_name.name;
-		cookie.nlen	=3D dentry->d_name.len;
-		cookie.fid.vid	=3D AFS_FS_I(inode)->volume->vid;
-		cookie.found	=3D 0;
-
-		fpos =3D 0;
-		ret =3D afs_dir_iterate(dir, &fpos, &cookie,
-				      afs_dir_lookup_filldir);
+		ret =3D afs_do_lookup(dir, dentry, &fid);
+		if (ret =3D=3D -ENOENT) {
+			_debug("%s: dirent not found", dentry->d_name.name);
+			goto not_found;
+		}
 		if (ret < 0) {
 			_debug("failed to iterate dir %s: %d",
 			       parent->d_name.name, ret);
 			goto out_bad;
 		}
=20
-		if (!cookie.found) {
-			_debug("%s: dirent not found", dentry->d_name.name);
-			goto not_found;
-		}
-
 		/* if the vnode ID has changed, then the dirent points to a
 		 * different file */
-		if (cookie.fid.vnode !=3D AFS_FS_I(inode)->fid.vnode) {
-			_debug("%s: dirent changed", dentry->d_name.name);
+		if (fid.vnode !=3D vnode->fid.vnode) {
+			_debug("%s: dirent changed [%u !=3D %u]",
+			       dentry->d_name.name, fid.vnode,
+			       vnode->fid.vnode);
 			goto not_found;
 		}
=20
 		/* if the vnode ID uniqifier has changed, then the file has
 		 * been deleted */
-		if (cookie.fid.unique !=3D AFS_FS_I(inode)->fid.unique) {
+		if (fid.unique !=3D vnode->fid.unique) {
 			_debug("%s: file deleted (uq %u -> %u I:%lu)",
-			       dentry->d_name.name,
-			       cookie.fid.unique,
-			       AFS_FS_I(inode)->fid.unique,
-			       inode->i_version);
-			spin_lock(&AFS_FS_I(inode)->lock);
-			AFS_FS_I(inode)->flags |=3D AFS_VNODE_DELETED;
-			spin_unlock(&AFS_FS_I(inode)->lock);
+			       dentry->d_name.name, fid.unique,
+			       vnode->fid.unique, inode->i_version);
+			spin_lock(&vnode->lock);
+			set_bit(AFS_VNODE_DELETED, &vnode->flags);
+			spin_unlock(&vnode->lock);
 			invalidate_remote_inode(inode);
 			goto out_bad;
 		}
+	}
+
+	/* if the directory's metadata were changed then the security may be
+	 * different and we may no longer have access */
+	mutex_lock(&vnode->cb_broken_lock);
=20
-		dentry->d_fsdata =3D
-			(void *) (unsigned long) AFS_FS_I(dir)->status.version;
+	if (test_and_clear_bit(AFS_VNODE_DIR_CHANGED, &vnode->flags) ||
+	    test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags)) {
+		_debug("%s: changed", dentry->d_name.name);
+		set_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
+		if (afs_vnode_fetch_status(vnode) < 0) {
+			mutex_unlock(&vnode->cb_broken_lock);
+			goto out_bad;
+		}
 	}
=20
+	if (test_bit(AFS_VNODE_DELETED, &vnode->flags)) {
+		_debug("%s: file already deleted", dentry->d_name.name);
+		mutex_unlock(&vnode->cb_broken_lock);
+		goto out_bad;
+	}
+
+	/* if the vnode's data version number changed then its contents are
+	 * different */
+	if (test_and_clear_bit(AFS_VNODE_ZAP_DATA, &vnode->flags)) {
+		_debug("zap data");
+		invalidate_remote_inode(inode);
+	}
+
+	if (S_ISDIR(inode->i_mode) &&
+	    (test_bit(AFS_VNODE_CHANGED, &vnode->flags) ||
+	     test_bit(AFS_VNODE_MODIFIED, &vnode->flags)))
+		afs_propagate_dir_changes(dentry);
+
+	clear_bit(AFS_VNODE_CHANGED, &vnode->flags);
+	clear_bit(AFS_VNODE_MODIFIED, &vnode->flags);
+	mutex_unlock(&vnode->cb_broken_lock);
+
 out_valid:
 	dput(parent);
 	_leave(" =3D 1 [valid]");
@@ -610,12 +683,10 @@ out_bad:
 			goto out_valid;
 	}
=20
-	shrink_dcache_parent(dentry);
-
 	_debug("dropping dentry %s/%s",
-	       dentry->d_parent->d_name.name, dentry->d_name.name);
+	       parent->d_name.name, dentry->d_name.name);
+	shrink_dcache_parent(dentry);
 	d_drop(dentry);
-
 	dput(parent);
=20
 	_leave(" =3D 0 [bad]");
@@ -635,10 +706,9 @@ static int afs_d_delete(struct dentry *dentry)
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
 		goto zap;
=20
-	if (dentry->d_inode) {
-		if (AFS_FS_I(dentry->d_inode)->flags & AFS_VNODE_DELETED)
+	if (dentry->d_inode &&
+	    test_bit(AFS_VNODE_DELETED, &AFS_FS_I(dentry->d_inode)->flags))
 			goto zap;
-	}
=20
 	_leave(" =3D 0 [keep]");
 	return 0;
diff --git a/fs/afs/errors.h b/fs/afs/errors.h
deleted file mode 100644
index bcc0a33..0000000
--- a/fs/afs/errors.h
+++ /dev/null
@@ -1,36 +0,0 @@
-/* AFS abort/error codes
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef AFS_ERRORS_H
-#define AFS_ERRORS_H
-
-#include "types.h"
-
-/*
- * file server abort codes
- */
-typedef enum {
-	VSALVAGE	=3D 101,	/* volume needs salvaging */
-	VNOVNODE	=3D 102,	/* no such file/dir (vnode) */
-	VNOVOL		=3D 103,	/* no such volume or volume unavailable */
-	VVOLEXISTS	=3D 104,	/* volume name already exists */
-	VNOSERVICE	=3D 105,	/* volume not currently in service */
-	VOFFLINE	=3D 106,	/* volume is currently offline (more info available=
 [VVL-spec]) */
-	VONLINE		=3D 107,	/* volume is already online */
-	VDISKFULL	=3D 108,	/* disk partition is full */
-	VOVERQUOTA	=3D 109,	/* volume's maximum quota exceeded */
-	VBUSY		=3D 110,	/* volume is temporarily unavailable */
-	VMOVED		=3D 111,	/* volume moved to new server - ask this FS where */
-} afs_rxfs_abort_t;
-
-extern int afs_abort_to_error(int);
-
-#endif /* AFS_ERRORS_H */
diff --git a/fs/afs/file.c b/fs/afs/file.c
index 01df30d..6990327 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -1,6 +1,6 @@
-/* file.c: AFS filesystem file handling
+/* AFS filesystem file handling
  *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2002, 2007 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -15,9 +15,6 @@
 #include <linux/slab.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
-#include "volume.h"
-#include "vnode.h"
-#include <rxrpc/call.h>
 #include "internal.h"
=20
 #if 0
@@ -80,12 +77,10 @@ static void afs_file_readpage_write_complete(void *=
cookie_data,
  */
 static int afs_file_readpage(struct file *file, struct page *page)
 {
-	struct afs_rxfs_fetch_descriptor desc;
-#ifdef AFS_CACHING_SUPPORT
-	struct cachefs_page *pageio;
-#endif
 	struct afs_vnode *vnode;
 	struct inode *inode;
+	size_t len;
+	off_t offset;
 	int ret;
=20
 	inode =3D page->mapping->host;
@@ -97,14 +92,10 @@ static int afs_file_readpage(struct file *file, str=
uct page *page)
 	BUG_ON(!PageLocked(page));
=20
 	ret =3D -ESTALE;
-	if (vnode->flags & AFS_VNODE_DELETED)
+	if (test_bit(AFS_VNODE_DELETED, &vnode->flags))
 		goto error;
=20
 #ifdef AFS_CACHING_SUPPORT
-	ret =3D cachefs_page_get_private(page, &pageio, GFP_NOIO);
-	if (ret < 0)
-		goto error;
-
 	/* is it cached? */
 	ret =3D cachefs_read_or_alloc_page(vnode->cache,
 					 page,
@@ -128,26 +119,19 @@ static int afs_file_readpage(struct file *file, s=
truct page *page)
 	case -ENOBUFS:
 	case -ENODATA:
 	default:
-		desc.fid	=3D vnode->fid;
-		desc.offset	=3D page->index << PAGE_CACHE_SHIFT;
-		desc.size	=3D min((size_t) (inode->i_size - desc.offset),
-				      (size_t) PAGE_SIZE);
-		desc.buffer	=3D kmap(page);
-
-		clear_page(desc.buffer);
+		offset =3D page->index << PAGE_CACHE_SHIFT;
+		len =3D min_t(size_t, i_size_read(inode) - offset, PAGE_SIZE);
=20
 		/* read the contents of the file from the server into the
 		 * page */
-		ret =3D afs_vnode_fetch_data(vnode, &desc);
-		kunmap(page);
+		ret =3D afs_vnode_fetch_data(vnode, offset, len, page);
 		if (ret < 0) {
-			if (ret=3D=3D-ENOENT) {
+			if (ret =3D=3D -ENOENT) {
 				_debug("got NOENT from server"
 				       " - marking file deleted and stale");
-				vnode->flags |=3D AFS_VNODE_DELETED;
+				set_bit(AFS_VNODE_DELETED, &vnode->flags);
 				ret =3D -ESTALE;
 			}
-
 #ifdef AFS_CACHING_SUPPORT
 			cachefs_uncache_page(vnode->cache, page);
 #endif
@@ -174,10 +158,9 @@ static int afs_file_readpage(struct file *file, st=
ruct page *page)
 	_leave(" =3D 0");
 	return 0;
=20
- error:
+error:
 	SetPageError(page);
 	unlock_page(page);
-
 	_leave(" =3D %d", ret);
 	return ret;
 }
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index f1c3a18..167ca61 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -1,6 +1,6 @@
-/* fsclient.c: AFS File Server client stubs
+/* AFS File Server client stubs
  *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2002, 2007 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -11,818 +11,396 @@
=20
 #include <linux/init.h>
 #include <linux/sched.h>
-#include <rxrpc/rxrpc.h>
-#include <rxrpc/transport.h>
-#include <rxrpc/connection.h>
-#include <rxrpc/call.h>
-#include "fsclient.h"
-#include "cmservice.h"
-#include "vnode.h"
-#include "server.h"
-#include "errors.h"
+#include <linux/circ_buf.h>
 #include "internal.h"
-
-#define FSFETCHSTATUS		132	/* AFS Fetch file status */
-#define FSFETCHDATA		130	/* AFS Fetch file data */
-#define FSGIVEUPCALLBACKS	147	/* AFS Discard callback promises */
-#define FSGETVOLUMEINFO		148	/* AFS Get root volume information */
-#define FSGETROOTVOLUME		151	/* AFS Get root volume name */
-#define FSLOOKUP		161	/* AFS lookup file in directory */
+#include "afs_fs.h"
=20
 /*
- * map afs abort codes to/from Linux error codes
- * - called with call->lock held
+ * decode an AFSFetchStatus block
  */
-static void afs_rxfs_aemap(struct rxrpc_call *call)
+static void xdr_decode_AFSFetchStatus(const __be32 **_bp,
+				      struct afs_vnode *vnode)
 {
-	switch (call->app_err_state) {
-	case RXRPC_ESTATE_LOCAL_ABORT:
-		call->app_abort_code =3D -call->app_errno;
-		break;
-	case RXRPC_ESTATE_PEER_ABORT:
-		call->app_errno =3D afs_abort_to_error(call->app_abort_code);
-		break;
-	default:
-		break;
+	const __be32 *bp =3D *_bp;
+	umode_t mode;
+	u64 data_version;
+	u32 changed =3D 0; /* becomes non-zero if ctime-type changes seen */
+
+#define EXTRACT(DST)				\
+	do {					\
+		u32 x =3D ntohl(*bp++);		\
+		changed |=3D DST - x;		\
+		DST =3D x;			\
+	} while (0)
+
+	vnode->status.if_version =3D ntohl(*bp++);
+	EXTRACT(vnode->status.type);
+	vnode->status.nlink =3D ntohl(*bp++);
+	EXTRACT(vnode->status.size);
+	data_version =3D ntohl(*bp++);
+	EXTRACT(vnode->status.author);
+	EXTRACT(vnode->status.owner);
+	EXTRACT(vnode->status.caller_access); /* call ticket dependent */
+	EXTRACT(vnode->status.anon_access);
+	EXTRACT(vnode->status.mode);
+	vnode->status.parent.vid =3D vnode->fid.vid;
+	EXTRACT(vnode->status.parent.vnode);
+	EXTRACT(vnode->status.parent.unique);
+	bp++; /* seg size */
+	vnode->status.mtime_client =3D ntohl(*bp++);
+	vnode->status.mtime_server =3D ntohl(*bp++);
+	bp++; /* group */
+	bp++; /* sync counter */
+	data_version |=3D (u64) ntohl(*bp++) << 32;
+	bp++; /* spare2 */
+	bp++; /* spare3 */
+	bp++; /* spare4 */
+	*_bp =3D bp;
+
+	if (changed) {
+		_debug("vnode changed");
+		set_bit(AFS_VNODE_CHANGED, &vnode->flags);
+		vnode->vfs_inode.i_uid		=3D vnode->status.owner;
+		vnode->vfs_inode.i_size		=3D vnode->status.size;
+		vnode->vfs_inode.i_version	=3D vnode->fid.unique;
+
+		vnode->status.mode &=3D S_IALLUGO;
+		mode =3D vnode->vfs_inode.i_mode;
+		mode &=3D ~S_IALLUGO;
+		mode |=3D vnode->status.mode;
+		vnode->vfs_inode.i_mode =3D mode;
+	}
+
+	_debug("vnode time %lx, %lx",
+	       vnode->status.mtime_client, vnode->status.mtime_server);
+	vnode->vfs_inode.i_ctime.tv_sec	=3D vnode->status.mtime_server;
+	vnode->vfs_inode.i_mtime	=3D vnode->vfs_inode.i_ctime;
+	vnode->vfs_inode.i_atime	=3D vnode->vfs_inode.i_ctime;
+
+	if (vnode->status.data_version !=3D data_version) {
+		_debug("vnode modified %llx", data_version);
+		vnode->status.data_version =3D data_version;
+		set_bit(AFS_VNODE_MODIFIED, &vnode->flags);
+		set_bit(AFS_VNODE_ZAP_DATA, &vnode->flags);
 	}
 }
=20
 /*
- * get the root volume name from a fileserver
- * - this operation doesn't seem to work correctly in OpenAFS server 1=
=2E2.2
+ * decode an AFSCallBack block
  */
-#if 0
-int afs_rxfs_get_root_volume(struct afs_server *server,
-			     char *buf, size_t *buflen)
+static void xdr_decode_AFSCallBack(const __be32 **_bp, struct afs_vnod=
e *vnode)
 {
-	struct rxrpc_connection *conn;
-	struct rxrpc_call *call;
-	struct kvec piov[2];
-	size_t sent;
-	int ret;
-	u32 param[1];
-
-	DECLARE_WAITQUEUE(myself, current);
-
-	kenter("%p,%p,%u",server, buf, *buflen);
-
-	/* get hold of the fileserver connection */
-	ret =3D afs_server_get_fsconn(server, &conn);
-	if (ret < 0)
-		goto out;
-
-	/* create a call through that connection */
-	ret =3D rxrpc_create_call(conn, NULL, NULL, afs_rxfs_aemap, &call);
-	if (ret < 0) {
-		printk("kAFS: Unable to create call: %d\n", ret);
-		goto out_put_conn;
-	}
-	call->app_opcode =3D FSGETROOTVOLUME;
-
-	/* we want to get event notifications from the call */
-	add_wait_queue(&call->waitq, &myself);
-
-	/* marshall the parameters */
-	param[0] =3D htonl(FSGETROOTVOLUME);
-
-	piov[0].iov_len =3D sizeof(param);
-	piov[0].iov_base =3D param;
-
-	/* send the parameters to the server */
-	ret =3D rxrpc_call_write_data(call, 1, piov, RXRPC_LAST_PACKET, GFP_N=
OFS,
-				    0, &sent);
-	if (ret < 0)
-		goto abort;
-
-	/* wait for the reply to completely arrive */
-	for (;;) {
-		set_current_state(TASK_INTERRUPTIBLE);
-		if (call->app_call_state !=3D RXRPC_CSTATE_CLNT_RCV_REPLY ||
-		    signal_pending(current))
-			break;
-		schedule();
-	}
-	set_current_state(TASK_RUNNING);
-
-	ret =3D -EINTR;
-	if (signal_pending(current))
-		goto abort;
-
-	switch (call->app_call_state) {
-	case RXRPC_CSTATE_ERROR:
-		ret =3D call->app_errno;
-		kdebug("Got Error: %d", ret);
-		goto out_unwait;
-
-	case RXRPC_CSTATE_CLNT_GOT_REPLY:
-		/* read the reply */
-		kdebug("Got Reply: qty=3D%d", call->app_ready_qty);
-
-		ret =3D -EBADMSG;
-		if (call->app_ready_qty <=3D 4)
-			goto abort;
-
-		ret =3D rxrpc_call_read_data(call, NULL, call->app_ready_qty, 0);
-		if (ret < 0)
-			goto abort;
-
-#if 0
-		/* unmarshall the reply */
-		bp =3D buffer;
-		for (loop =3D 0; loop < 65; loop++)
-			entry->name[loop] =3D ntohl(*bp++);
-		entry->name[64] =3D 0;
-
-		entry->type =3D ntohl(*bp++);
-		entry->num_servers =3D ntohl(*bp++);
-
-		for (loop =3D 0; loop < 8; loop++)
-			entry->servers[loop].addr.s_addr =3D *bp++;
-
-		for (loop =3D 0; loop < 8; loop++)
-			entry->servers[loop].partition =3D ntohl(*bp++);
-
-		for (loop =3D 0; loop < 8; loop++)
-			entry->servers[loop].flags =3D ntohl(*bp++);
-
-		for (loop =3D 0; loop < 3; loop++)
-			entry->volume_ids[loop] =3D ntohl(*bp++);
-
-		entry->clone_id =3D ntohl(*bp++);
-		entry->flags =3D ntohl(*bp);
-#endif
+	const __be32 *bp =3D *_bp;
=20
-		/* success */
-		ret =3D 0;
-		goto out_unwait;
-
-	default:
-		BUG();
-	}
-
-abort:
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	rxrpc_call_abort(call, ret);
-	schedule();
-out_unwait:
-	set_current_state(TASK_RUNNING);
-	remove_wait_queue(&call->waitq, &myself);
-	rxrpc_put_call(call);
-out_put_conn:
-	afs_server_release_fsconn(server, conn);
-out:
-	kleave("");
-	return ret;
+	vnode->cb_version	=3D ntohl(*bp++);
+	vnode->cb_expiry	=3D ntohl(*bp++);
+	vnode->cb_type		=3D ntohl(*bp++);
+	vnode->cb_expires	=3D vnode->cb_expiry + get_seconds();
+	*_bp =3D bp;
 }
-#endif
=20
 /*
- * get information about a volume
+ * decode an AFSVolSync block
  */
-#if 0
-int afs_rxfs_get_volume_info(struct afs_server *server,
-			     const char *name,
-			     struct afs_volume_info *vinfo)
+static void xdr_decode_AFSVolSync(const __be32 **_bp,
+				  struct afs_volsync *volsync)
 {
-	struct rxrpc_connection *conn;
-	struct rxrpc_call *call;
-	struct kvec piov[3];
-	size_t sent;
-	int ret;
-	u32 param[2], *bp, zero;
+	const __be32 *bp =3D *_bp;
=20
-	DECLARE_WAITQUEUE(myself, current);
+	volsync->creation =3D ntohl(*bp++);
+	bp++; /* spare2 */
+	bp++; /* spare3 */
+	bp++; /* spare4 */
+	bp++; /* spare5 */
+	bp++; /* spare6 */
+	*_bp =3D bp;
+}
=20
-	_enter("%p,%s,%p", server, name, vinfo);
+/*
+ * deliver reply data to an FS.FetchStatus
+ */
+static int afs_deliver_fs_fetch_status(struct afs_call *call,
+				       struct sk_buff *skb, bool last)
+{
+	const __be32 *bp;
=20
-	/* get hold of the fileserver connection */
-	ret =3D afs_server_get_fsconn(server, &conn);
-	if (ret < 0)
-		goto out;
+	_enter(",,%u", last);
=20
-	/* create a call through that connection */
-	ret =3D rxrpc_create_call(conn, NULL, NULL, afs_rxfs_aemap, &call);
-	if (ret < 0) {
-		printk("kAFS: Unable to create call: %d\n", ret);
-		goto out_put_conn;
-	}
-	call->app_opcode =3D FSGETVOLUMEINFO;
+	afs_transfer_reply(call, skb);
+	if (!last)
+		return 0;
=20
-	/* we want to get event notifications from the call */
-	add_wait_queue(&call->waitq, &myself);
+	if (call->reply_size !=3D call->reply_max)
+		return -EBADMSG;
=20
-	/* marshall the parameters */
-	piov[1].iov_len =3D strlen(name);
-	piov[1].iov_base =3D (char *) name;
-
-	zero =3D 0;
-	piov[2].iov_len =3D (4 - (piov[1].iov_len & 3)) & 3;
-	piov[2].iov_base =3D &zero;
-
-	param[0] =3D htonl(FSGETVOLUMEINFO);
-	param[1] =3D htonl(piov[1].iov_len);
-
-	piov[0].iov_len =3D sizeof(param);
-	piov[0].iov_base =3D param;
-
-	/* send the parameters to the server */
-	ret =3D rxrpc_call_write_data(call, 3, piov, RXRPC_LAST_PACKET, GFP_N=
OFS,
-				    0, &sent);
-	if (ret < 0)
-		goto abort;
-
-	/* wait for the reply to completely arrive */
-	bp =3D rxrpc_call_alloc_scratch(call, 64);
-
-	ret =3D rxrpc_call_read_data(call, bp, 64,
-				   RXRPC_CALL_READ_BLOCK |
-				   RXRPC_CALL_READ_ALL);
-	if (ret < 0) {
-		if (ret =3D=3D -ECONNABORTED) {
-			ret =3D call->app_errno;
-			goto out_unwait;
-		}
-		goto abort;
-	}
+	/* unmarshall the reply once we've received all of it */
+	bp =3D call->buffer;
+	xdr_decode_AFSFetchStatus(&bp, call->reply);
+	xdr_decode_AFSCallBack(&bp, call->reply);
+	if (call->reply2)
+		xdr_decode_AFSVolSync(&bp, call->reply2);
=20
-	/* unmarshall the reply */
-	vinfo->vid =3D ntohl(*bp++);
-	vinfo->type =3D ntohl(*bp++);
-
-	vinfo->type_vids[0] =3D ntohl(*bp++);
-	vinfo->type_vids[1] =3D ntohl(*bp++);
-	vinfo->type_vids[2] =3D ntohl(*bp++);
-	vinfo->type_vids[3] =3D ntohl(*bp++);
-	vinfo->type_vids[4] =3D ntohl(*bp++);
-
-	vinfo->nservers =3D ntohl(*bp++);
-	vinfo->servers[0].addr.s_addr =3D *bp++;
-	vinfo->servers[1].addr.s_addr =3D *bp++;
-	vinfo->servers[2].addr.s_addr =3D *bp++;
-	vinfo->servers[3].addr.s_addr =3D *bp++;
-	vinfo->servers[4].addr.s_addr =3D *bp++;
-	vinfo->servers[5].addr.s_addr =3D *bp++;
-	vinfo->servers[6].addr.s_addr =3D *bp++;
-	vinfo->servers[7].addr.s_addr =3D *bp++;
-
-	ret =3D -EBADMSG;
-	if (vinfo->nservers > 8)
-		goto abort;
-
-	/* success */
-	ret =3D 0;
-
-out_unwait:
-	set_current_state(TASK_RUNNING);
-	remove_wait_queue(&call->waitq, &myself);
-	rxrpc_put_call(call);
-out_put_conn:
-	afs_server_release_fsconn(server, conn);
-out:
-	_leave("");
-	return ret;
-
-abort:
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	rxrpc_call_abort(call, ret);
-	schedule();
-	goto out_unwait;
+	_leave(" =3D 0 [done]");
+	return 0;
 }
-#endif
+
+/*
+ * FS.FetchStatus operation type
+ */
+static const struct afs_call_type afs_RXFSFetchStatus =3D {
+	.deliver	=3D afs_deliver_fs_fetch_status,
+	.abort_to_error	=3D afs_abort_to_error,
+	.destructor	=3D afs_flat_call_destructor,
+};
=20
 /*
  * fetch the status information for a file
  */
-int afs_rxfs_fetch_file_status(struct afs_server *server,
-			       struct afs_vnode *vnode,
-			       struct afs_volsync *volsync)
+int afs_fs_fetch_file_status(struct afs_server *server,
+			     struct afs_vnode *vnode,
+			     struct afs_volsync *volsync,
+			     const struct afs_wait_mode *wait_mode)
 {
-	struct afs_server_callslot callslot;
-	struct rxrpc_call *call;
-	struct kvec piov[1];
-	size_t sent;
-	int ret;
+	struct afs_call *call;
 	__be32 *bp;
=20
-	DECLARE_WAITQUEUE(myself, current);
+	_enter("");
=20
-	_enter("%p,{%u,%u,%u}",
-	       server, vnode->fid.vid, vnode->fid.vnode, vnode->fid.unique);
+	call =3D afs_alloc_flat_call(&afs_RXFSFetchStatus, 16, 120);
+	if (!call)
+		return -ENOMEM;
=20
-	/* get hold of the fileserver connection */
-	ret =3D afs_server_request_callslot(server, &callslot);
-	if (ret < 0)
-		goto out;
-
-	/* create a call through that connection */
-	ret =3D rxrpc_create_call(callslot.conn, NULL, NULL, afs_rxfs_aemap,
-				&call);
-	if (ret < 0) {
-		printk("kAFS: Unable to create call: %d\n", ret);
-		goto out_put_conn;
-	}
-	call->app_opcode =3D FSFETCHSTATUS;
-
-	/* we want to get event notifications from the call */
-	add_wait_queue(&call->waitq, &myself);
+	call->reply =3D vnode;
+	call->reply2 =3D volsync;
+	call->service_id =3D FS_SERVICE;
+	call->port =3D htons(AFS_FS_PORT);
=20
 	/* marshall the parameters */
-	bp =3D rxrpc_call_alloc_scratch(call, 16);
+	bp =3D call->request;
 	bp[0] =3D htonl(FSFETCHSTATUS);
 	bp[1] =3D htonl(vnode->fid.vid);
 	bp[2] =3D htonl(vnode->fid.vnode);
 	bp[3] =3D htonl(vnode->fid.unique);
=20
-	piov[0].iov_len =3D 16;
-	piov[0].iov_base =3D bp;
-
-	/* send the parameters to the server */
-	ret =3D rxrpc_call_write_data(call, 1, piov, RXRPC_LAST_PACKET, GFP_N=
OFS,
-				    0, &sent);
-	if (ret < 0)
-		goto abort;
-
-	/* wait for the reply to completely arrive */
-	bp =3D rxrpc_call_alloc_scratch(call, 120);
-
-	ret =3D rxrpc_call_read_data(call, bp, 120,
-				   RXRPC_CALL_READ_BLOCK |
-				   RXRPC_CALL_READ_ALL);
-	if (ret < 0) {
-		if (ret =3D=3D -ECONNABORTED) {
-			ret =3D call->app_errno;
-			goto out_unwait;
-		}
-		goto abort;
-	}
-
-	/* unmarshall the reply */
-	vnode->status.if_version	=3D ntohl(*bp++);
-	vnode->status.type		=3D ntohl(*bp++);
-	vnode->status.nlink		=3D ntohl(*bp++);
-	vnode->status.size		=3D ntohl(*bp++);
-	vnode->status.version		=3D ntohl(*bp++);
-	vnode->status.author		=3D ntohl(*bp++);
-	vnode->status.owner		=3D ntohl(*bp++);
-	vnode->status.caller_access	=3D ntohl(*bp++);
-	vnode->status.anon_access	=3D ntohl(*bp++);
-	vnode->status.mode		=3D ntohl(*bp++);
-	vnode->status.parent.vid	=3D vnode->fid.vid;
-	vnode->status.parent.vnode	=3D ntohl(*bp++);
-	vnode->status.parent.unique	=3D ntohl(*bp++);
-	bp++; /* seg size */
-	vnode->status.mtime_client	=3D ntohl(*bp++);
-	vnode->status.mtime_server	=3D ntohl(*bp++);
-	bp++; /* group */
-	bp++; /* sync counter */
-	vnode->status.version |=3D ((unsigned long long) ntohl(*bp++)) << 32;
-	bp++; /* spare2 */
-	bp++; /* spare3 */
-	bp++; /* spare4 */
-
-	vnode->cb_version		=3D ntohl(*bp++);
-	vnode->cb_expiry		=3D ntohl(*bp++);
-	vnode->cb_type			=3D ntohl(*bp++);
-
-	if (volsync) {
-		volsync->creation	=3D ntohl(*bp++);
-		bp++; /* spare2 */
-		bp++; /* spare3 */
-		bp++; /* spare4 */
-		bp++; /* spare5 */
-		bp++; /* spare6 */
-	}
-
-	/* success */
-	ret =3D 0;
-
-out_unwait:
-	set_current_state(TASK_RUNNING);
-	remove_wait_queue(&call->waitq, &myself);
-	rxrpc_put_call(call);
-out_put_conn:
-	afs_server_release_callslot(server, &callslot);
-out:
-	_leave("");
-	return ret;
-
-abort:
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	rxrpc_call_abort(call, ret);
-	schedule();
-	goto out_unwait;
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
 }
=20
 /*
- * fetch the contents of a file or directory
+ * deliver reply data to an FS.FetchData
  */
-int afs_rxfs_fetch_file_data(struct afs_server *server,
-			     struct afs_vnode *vnode,
-			     struct afs_rxfs_fetch_descriptor *desc,
-			     struct afs_volsync *volsync)
+static int afs_deliver_fs_fetch_data(struct afs_call *call,
+				     struct sk_buff *skb, bool last)
 {
-	struct afs_server_callslot callslot;
-	struct rxrpc_call *call;
-	struct kvec piov[1];
-	size_t sent;
+	const __be32 *bp;
+	struct page *page;
+	void *buffer;
 	int ret;
-	__be32 *bp;
=20
-	DECLARE_WAITQUEUE(myself, current);
-
-	_enter("%p,{fid=3D{%u,%u,%u},sz=3D%Zu,of=3D%lu}",
-	       server,
-	       desc->fid.vid,
-	       desc->fid.vnode,
-	       desc->fid.unique,
-	       desc->size,
-	       desc->offset);
-
-	/* get hold of the fileserver connection */
-	ret =3D afs_server_request_callslot(server, &callslot);
-	if (ret < 0)
-		goto out;
-
-	/* create a call through that connection */
-	ret =3D rxrpc_create_call(callslot.conn, NULL, NULL, afs_rxfs_aemap, =
&call);
-	if (ret < 0) {
-		printk("kAFS: Unable to create call: %d\n", ret);
-		goto out_put_conn;
-	}
-	call->app_opcode =3D FSFETCHDATA;
+	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+
+	switch (call->unmarshall) {
+	case 0:
+		call->offset =3D 0;
+		call->unmarshall++;
+
+		/* extract the returned data length */
+	case 1:
+		_debug("extract data length");
+		ret =3D afs_extract_data(call, skb, last, &call->tmp, 4);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
+		}
=20
-	/* we want to get event notifications from the call */
-	add_wait_queue(&call->waitq, &myself);
+		call->count =3D ntohl(call->tmp);
+		_debug("DATA length: %u", call->count);
+		if (call->count > PAGE_SIZE)
+			return -EBADMSG;
+		call->offset =3D 0;
+		call->unmarshall++;
+
+		if (call->count < PAGE_SIZE) {
+			buffer =3D kmap_atomic(call->reply3, KM_USER0);
+			memset(buffer + PAGE_SIZE - call->count, 0,
+			       call->count);
+			kunmap_atomic(buffer, KM_USER0);
+		}
=20
-	/* marshall the parameters */
-	bp =3D rxrpc_call_alloc_scratch(call, 24);
-	bp[0] =3D htonl(FSFETCHDATA);
-	bp[1] =3D htonl(desc->fid.vid);
-	bp[2] =3D htonl(desc->fid.vnode);
-	bp[3] =3D htonl(desc->fid.unique);
-	bp[4] =3D htonl(desc->offset);
-	bp[5] =3D htonl(desc->size);
-
-	piov[0].iov_len =3D 24;
-	piov[0].iov_base =3D bp;
-
-	/* send the parameters to the server */
-	ret =3D rxrpc_call_write_data(call, 1, piov, RXRPC_LAST_PACKET, GFP_N=
OFS,
-				    0, &sent);
-	if (ret < 0)
-		goto abort;
-
-	/* wait for the data count to arrive */
-	ret =3D rxrpc_call_read_data(call, bp, 4, RXRPC_CALL_READ_BLOCK);
-	if (ret < 0)
-		goto read_failed;
-
-	desc->actual =3D ntohl(bp[0]);
-	if (desc->actual !=3D desc->size) {
-		ret =3D -EBADMSG;
-		goto abort;
-	}
+		/* extract the returned data */
+	case 2:
+		_debug("extract data");
+		page =3D call->reply3;
+		buffer =3D kmap_atomic(page, KM_USER0);
+		ret =3D afs_extract_data(call, skb, last, buffer, call->count);
+		kunmap_atomic(buffer, KM_USER0);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
+		}
=20
-	/* call the app to read the actual data */
-	rxrpc_call_reset_scratch(call);
-
-	ret =3D rxrpc_call_read_data(call, desc->buffer, desc->actual,
-				   RXRPC_CALL_READ_BLOCK);
-	if (ret < 0)
-		goto read_failed;
-
-	/* wait for the rest of the reply to completely arrive */
-	rxrpc_call_reset_scratch(call);
-	bp =3D rxrpc_call_alloc_scratch(call, 120);
-
-	ret =3D rxrpc_call_read_data(call, bp, 120,
-				   RXRPC_CALL_READ_BLOCK |
-				   RXRPC_CALL_READ_ALL);
-	if (ret < 0)
-		goto read_failed;
-
-	/* unmarshall the reply */
-	vnode->status.if_version	=3D ntohl(*bp++);
-	vnode->status.type		=3D ntohl(*bp++);
-	vnode->status.nlink		=3D ntohl(*bp++);
-	vnode->status.size		=3D ntohl(*bp++);
-	vnode->status.version		=3D ntohl(*bp++);
-	vnode->status.author		=3D ntohl(*bp++);
-	vnode->status.owner		=3D ntohl(*bp++);
-	vnode->status.caller_access	=3D ntohl(*bp++);
-	vnode->status.anon_access	=3D ntohl(*bp++);
-	vnode->status.mode		=3D ntohl(*bp++);
-	vnode->status.parent.vid	=3D desc->fid.vid;
-	vnode->status.parent.vnode	=3D ntohl(*bp++);
-	vnode->status.parent.unique	=3D ntohl(*bp++);
-	bp++; /* seg size */
-	vnode->status.mtime_client	=3D ntohl(*bp++);
-	vnode->status.mtime_server	=3D ntohl(*bp++);
-	bp++; /* group */
-	bp++; /* sync counter */
-	vnode->status.version |=3D ((unsigned long long) ntohl(*bp++)) << 32;
-	bp++; /* spare2 */
-	bp++; /* spare3 */
-	bp++; /* spare4 */
+		call->offset =3D 0;
+		call->unmarshall++;
=20
-	vnode->cb_version		=3D ntohl(*bp++);
-	vnode->cb_expiry		=3D ntohl(*bp++);
-	vnode->cb_type			=3D ntohl(*bp++);
-
-	if (volsync) {
-		volsync->creation	=3D ntohl(*bp++);
-		bp++; /* spare2 */
-		bp++; /* spare3 */
-		bp++; /* spare4 */
-		bp++; /* spare5 */
-		bp++; /* spare6 */
-	}
+		/* extract the metadata */
+	case 3:
+		ret =3D afs_extract_data(call, skb, last, call->buffer, 120);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
+		}
+
+		bp =3D call->buffer;
+		xdr_decode_AFSFetchStatus(&bp, call->reply);
+		xdr_decode_AFSCallBack(&bp, call->reply);
+		if (call->reply2)
+			xdr_decode_AFSVolSync(&bp, call->reply2);
+
+		call->offset =3D 0;
+		call->unmarshall++;
=20
-	/* success */
-	ret =3D 0;
-
-out_unwait:
-	set_current_state(TASK_RUNNING);
-	remove_wait_queue(&call->waitq,&myself);
-	rxrpc_put_call(call);
-out_put_conn:
-	afs_server_release_callslot(server, &callslot);
-out:
-	_leave(" =3D %d", ret);
-	return ret;
-
-read_failed:
-	if (ret =3D=3D -ECONNABORTED) {
-		ret =3D call->app_errno;
-		goto out_unwait;
+	case 4:
+		_debug("trailer");
+		if (skb->len !=3D 0)
+			return -EBADMSG;
+		break;
 	}
=20
-abort:
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	rxrpc_call_abort(call, ret);
-	schedule();
-	goto out_unwait;
+	if (!last)
+		return 0;
+
+	_leave(" =3D 0 [done]");
+	return 0;
 }
=20
 /*
- * ask the AFS fileserver to discard a callback request on a file
+ * FS.FetchData operation type
  */
-int afs_rxfs_give_up_callback(struct afs_server *server,
-			      struct afs_vnode *vnode)
+static const struct afs_call_type afs_RXFSFetchData =3D {
+	.deliver	=3D afs_deliver_fs_fetch_data,
+	.abort_to_error	=3D afs_abort_to_error,
+	.destructor	=3D afs_flat_call_destructor,
+};
+
+/*
+ * fetch data from a file
+ */
+int afs_fs_fetch_data(struct afs_server *server,
+		      struct afs_vnode *vnode,
+		      off_t offset, size_t length,
+		      struct page *buffer,
+		      struct afs_volsync *volsync,
+		      const struct afs_wait_mode *wait_mode)
 {
-	struct afs_server_callslot callslot;
-	struct rxrpc_call *call;
-	struct kvec piov[1];
-	size_t sent;
-	int ret;
+	struct afs_call *call;
 	__be32 *bp;
=20
-	DECLARE_WAITQUEUE(myself, current);
+	_enter("");
=20
-	_enter("%p,{%u,%u,%u}",
-	       server, vnode->fid.vid, vnode->fid.vnode, vnode->fid.unique);
+	call =3D afs_alloc_flat_call(&afs_RXFSFetchData, 24, 120);
+	if (!call)
+		return -ENOMEM;
=20
-	/* get hold of the fileserver connection */
-	ret =3D afs_server_request_callslot(server, &callslot);
-	if (ret < 0)
-		goto out;
-
-	/* create a call through that connection */
-	ret =3D rxrpc_create_call(callslot.conn, NULL, NULL, afs_rxfs_aemap, =
&call);
-	if (ret < 0) {
-		printk("kAFS: Unable to create call: %d\n", ret);
-		goto out_put_conn;
-	}
-	call->app_opcode =3D FSGIVEUPCALLBACKS;
-
-	/* we want to get event notifications from the call */
-	add_wait_queue(&call->waitq, &myself);
+	call->reply =3D vnode;
+	call->reply2 =3D volsync;
+	call->reply3 =3D buffer;
+	call->service_id =3D FS_SERVICE;
+	call->port =3D htons(AFS_FS_PORT);
=20
 	/* marshall the parameters */
-	bp =3D rxrpc_call_alloc_scratch(call, (1 + 4 + 4) * 4);
-
-	piov[0].iov_len =3D (1 + 4 + 4) * 4;
-	piov[0].iov_base =3D bp;
-
-	*bp++ =3D htonl(FSGIVEUPCALLBACKS);
-	*bp++ =3D htonl(1);
-	*bp++ =3D htonl(vnode->fid.vid);
-	*bp++ =3D htonl(vnode->fid.vnode);
-	*bp++ =3D htonl(vnode->fid.unique);
-	*bp++ =3D htonl(1);
-	*bp++ =3D htonl(vnode->cb_version);
-	*bp++ =3D htonl(vnode->cb_expiry);
-	*bp++ =3D htonl(vnode->cb_type);
-
-	/* send the parameters to the server */
-	ret =3D rxrpc_call_write_data(call, 1, piov, RXRPC_LAST_PACKET, GFP_N=
OFS,
-				    0, &sent);
-	if (ret < 0)
-		goto abort;
-
-	/* wait for the reply to completely arrive */
-	for (;;) {
-		set_current_state(TASK_INTERRUPTIBLE);
-		if (call->app_call_state !=3D RXRPC_CSTATE_CLNT_RCV_REPLY ||
-		    signal_pending(current))
-			break;
-		schedule();
-	}
-	set_current_state(TASK_RUNNING);
-
-	ret =3D -EINTR;
-	if (signal_pending(current))
-		goto abort;
-
-	switch (call->app_call_state) {
-	case RXRPC_CSTATE_ERROR:
-		ret =3D call->app_errno;
-		goto out_unwait;
+	bp =3D call->request;
+	bp[0] =3D htonl(FSFETCHDATA);
+	bp[1] =3D htonl(vnode->fid.vid);
+	bp[2] =3D htonl(vnode->fid.vnode);
+	bp[3] =3D htonl(vnode->fid.unique);
+	bp[4] =3D htonl(offset);
+	bp[5] =3D htonl(length);
=20
-	case RXRPC_CSTATE_CLNT_GOT_REPLY:
-		ret =3D 0;
-		goto out_unwait;
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+}
=20
-	default:
-		BUG();
-	}
+/*
+ * deliver reply data to an FS.GiveUpCallBacks
+ */
+static int afs_deliver_fs_give_up_callbacks(struct afs_call *call,
+					    struct sk_buff *skb, bool last)
+{
+	_enter(",{%u},%d", skb->len, last);
=20
-out_unwait:
-	set_current_state(TASK_RUNNING);
-	remove_wait_queue(&call->waitq, &myself);
-	rxrpc_put_call(call);
-out_put_conn:
-	afs_server_release_callslot(server, &callslot);
-out:
-	_leave("");
-	return ret;
-
-abort:
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	rxrpc_call_abort(call, ret);
-	schedule();
-	goto out_unwait;
+	if (skb->len > 0)
+		return -EBADMSG; /* shouldn't be any reply data */
+	return 0;
 }
=20
 /*
- * look a filename up in a directory
- * - this operation doesn't seem to work correctly in OpenAFS server 1=
=2E2.2
+ * FS.GiveUpCallBacks operation type
+ */
+static const struct afs_call_type afs_RXFSGiveUpCallBacks =3D {
+	.deliver	=3D afs_deliver_fs_give_up_callbacks,
+	.abort_to_error	=3D afs_abort_to_error,
+	.destructor	=3D afs_flat_call_destructor,
+};
+
+/*
+ * give up a set of callbacks
+ * - the callbacks are held in the server->cb_break ring
  */
-#if 0
-int afs_rxfs_lookup(struct afs_server *server,
-		    struct afs_vnode *dir,
-		    const char *filename,
-		    struct afs_vnode *vnode,
-		    struct afs_volsync *volsync)
+int afs_fs_give_up_callbacks(struct afs_server *server,
+			     const struct afs_wait_mode *wait_mode)
 {
-	struct rxrpc_connection *conn;
-	struct rxrpc_call *call;
-	struct kvec piov[3];
-	size_t sent;
-	int ret;
-	u32 *bp, zero;
+	struct afs_call *call;
+	size_t ncallbacks;
+	__be32 *bp, *tp;
+	int loop;
=20
-	DECLARE_WAITQUEUE(myself, current);
+	ncallbacks =3D CIRC_CNT(server->cb_break_head, server->cb_break_tail,
+			      ARRAY_SIZE(server->cb_break));
=20
-	kenter("%p,{%u,%u,%u},%s",
-	       server, fid->vid, fid->vnode, fid->unique, filename);
+	_enter("{%zu},", ncallbacks);
=20
-	/* get hold of the fileserver connection */
-	ret =3D afs_server_get_fsconn(server, &conn);
-	if (ret < 0)
-		goto out;
+	if (ncallbacks =3D=3D 0)
+		return 0;
+	if (ncallbacks > AFSCBMAX)
+		ncallbacks =3D AFSCBMAX;
=20
-	/* create a call through that connection */
-	ret =3D rxrpc_create_call(conn, NULL, NULL, afs_rxfs_aemap, &call);
-	if (ret < 0) {
-		printk("kAFS: Unable to create call: %d\n", ret);
-		goto out_put_conn;
-	}
-	call->app_opcode =3D FSLOOKUP;
+	_debug("break %zu callbacks", ncallbacks);
=20
-	/* we want to get event notifications from the call */
-	add_wait_queue(&call->waitq,&myself);
+	call =3D afs_alloc_flat_call(&afs_RXFSGiveUpCallBacks,
+				   12 + ncallbacks * 6 * 4, 0);
+	if (!call)
+		return -ENOMEM;
+
+	call->service_id =3D FS_SERVICE;
+	call->port =3D htons(AFS_FS_PORT);
=20
 	/* marshall the parameters */
-	bp =3D rxrpc_call_alloc_scratch(call, 20);
-
-	zero =3D 0;
-
-	piov[0].iov_len =3D 20;
-	piov[0].iov_base =3D bp;
-	piov[1].iov_len =3D strlen(filename);
-	piov[1].iov_base =3D (char *) filename;
-	piov[2].iov_len =3D (4 - (piov[1].iov_len & 3)) & 3;
-	piov[2].iov_base =3D &zero;
-
-	*bp++ =3D htonl(FSLOOKUP);
-	*bp++ =3D htonl(dirfid->vid);
-	*bp++ =3D htonl(dirfid->vnode);
-	*bp++ =3D htonl(dirfid->unique);
-	*bp++ =3D htonl(piov[1].iov_len);
-
-	/* send the parameters to the server */
-	ret =3D rxrpc_call_write_data(call, 3, piov, RXRPC_LAST_PACKET, GFP_N=
OFS,
-				    0, &sent);
-	if (ret < 0)
-		goto abort;
-
-	/* wait for the reply to completely arrive */
-	bp =3D rxrpc_call_alloc_scratch(call, 220);
-
-	ret =3D rxrpc_call_read_data(call, bp, 220,
-				   RXRPC_CALL_READ_BLOCK |
-				   RXRPC_CALL_READ_ALL);
-	if (ret < 0) {
-		if (ret =3D=3D -ECONNABORTED) {
-			ret =3D call->app_errno;
-			goto out_unwait;
-		}
-		goto abort;
+	bp =3D call->request;
+	tp =3D bp + 2 + ncallbacks * 3;
+	*bp++ =3D htonl(FSGIVEUPCALLBACKS);
+	*bp++ =3D htonl(ncallbacks);
+	*tp++ =3D htonl(ncallbacks);
+
+	atomic_sub(ncallbacks, &server->cb_break_n);
+	for (loop =3D ncallbacks; loop > 0; loop--) {
+		struct afs_callback *cb =3D
+			&server->cb_break[server->cb_break_tail];
+
+		*bp++ =3D htonl(cb->fid.vid);
+		*bp++ =3D htonl(cb->fid.vnode);
+		*bp++ =3D htonl(cb->fid.unique);
+		*tp++ =3D htonl(cb->version);
+		*tp++ =3D htonl(cb->expiry);
+		*tp++ =3D htonl(cb->type);
+		smp_mb();
+		server->cb_break_tail =3D
+			(server->cb_break_tail + 1) &
+			(ARRAY_SIZE(server->cb_break) - 1);
 	}
=20
-	/* unmarshall the reply */
-	fid->vid		=3D ntohl(*bp++);
-	fid->vnode		=3D ntohl(*bp++);
-	fid->unique		=3D ntohl(*bp++);
-
-	vnode->status.if_version	=3D ntohl(*bp++);
-	vnode->status.type		=3D ntohl(*bp++);
-	vnode->status.nlink		=3D ntohl(*bp++);
-	vnode->status.size		=3D ntohl(*bp++);
-	vnode->status.version		=3D ntohl(*bp++);
-	vnode->status.author		=3D ntohl(*bp++);
-	vnode->status.owner		=3D ntohl(*bp++);
-	vnode->status.caller_access	=3D ntohl(*bp++);
-	vnode->status.anon_access	=3D ntohl(*bp++);
-	vnode->status.mode		=3D ntohl(*bp++);
-	vnode->status.parent.vid	=3D dirfid->vid;
-	vnode->status.parent.vnode	=3D ntohl(*bp++);
-	vnode->status.parent.unique	=3D ntohl(*bp++);
-	bp++; /* seg size */
-	vnode->status.mtime_client	=3D ntohl(*bp++);
-	vnode->status.mtime_server	=3D ntohl(*bp++);
-	bp++; /* group */
-	bp++; /* sync counter */
-	vnode->status.version |=3D ((unsigned long long) ntohl(*bp++)) << 32;
-	bp++; /* spare2 */
-	bp++; /* spare3 */
-	bp++; /* spare4 */
-
-	dir->status.if_version		=3D ntohl(*bp++);
-	dir->status.type		=3D ntohl(*bp++);
-	dir->status.nlink		=3D ntohl(*bp++);
-	dir->status.size		=3D ntohl(*bp++);
-	dir->status.version		=3D ntohl(*bp++);
-	dir->status.author		=3D ntohl(*bp++);
-	dir->status.owner		=3D ntohl(*bp++);
-	dir->status.caller_access	=3D ntohl(*bp++);
-	dir->status.anon_access		=3D ntohl(*bp++);
-	dir->status.mode		=3D ntohl(*bp++);
-	dir->status.parent.vid		=3D dirfid->vid;
-	dir->status.parent.vnode	=3D ntohl(*bp++);
-	dir->status.parent.unique	=3D ntohl(*bp++);
-	bp++; /* seg size */
-	dir->status.mtime_client	=3D ntohl(*bp++);
-	dir->status.mtime_server	=3D ntohl(*bp++);
-	bp++; /* group */
-	bp++; /* sync counter */
-	dir->status.version |=3D ((unsigned long long) ntohl(*bp++)) << 32;
-	bp++; /* spare2 */
-	bp++; /* spare3 */
-	bp++; /* spare4 */
-
-	callback->fid		=3D *fid;
-	callback->version	=3D ntohl(*bp++);
-	callback->expiry	=3D ntohl(*bp++);
-	callback->type		=3D ntohl(*bp++);
-
-	if (volsync) {
-		volsync->creation	=3D ntohl(*bp++);
-		bp++; /* spare2 */
-		bp++; /* spare3 */
-		bp++; /* spare4 */
-		bp++; /* spare5 */
-		bp++; /* spare6 */
-	}
+	ASSERT(ncallbacks > 0);
+	wake_up_nr(&server->cb_break_waitq, ncallbacks);
=20
-	/* success */
-	ret =3D 0;
-
-out_unwait:
-	set_current_state(TASK_RUNNING);
-	remove_wait_queue(&call->waitq, &myself);
-	rxrpc_put_call(call);
-out_put_conn:
-	afs_server_release_fsconn(server, conn);
-out:
-	kleave("");
-	return ret;
-
-abort:
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	rxrpc_call_abort(call, ret);
-	schedule();
-	goto out_unwait;
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
 }
-#endif
diff --git a/fs/afs/fsclient.h b/fs/afs/fsclient.h
deleted file mode 100644
index e2b0b7b..0000000
--- a/fs/afs/fsclient.h
+++ /dev/null
@@ -1,54 +0,0 @@
-/* AFS File Server client stub declarations
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef AFS_FSCLIENT_H
-#define AFS_FSCLIENT_H
-
-#include "server.h"
-
-extern int afs_rxfs_get_volume_info(struct afs_server *,
-				    const char *,
-				    struct afs_volume_info *);
-
-extern int afs_rxfs_fetch_file_status(struct afs_server *,
-				      struct afs_vnode *,
-				      struct afs_volsync *);
-
-struct afs_rxfs_fetch_descriptor {
-	struct afs_fid	fid;		/* file ID to fetch */
-	size_t		size;		/* total number of bytes to fetch */
-	off_t		offset;		/* offset in file to start from */
-	void		*buffer;	/* read buffer */
-	size_t		actual;		/* actual size sent back by server */
-};
-
-extern int afs_rxfs_fetch_file_data(struct afs_server *,
-				    struct afs_vnode *,
-				    struct afs_rxfs_fetch_descriptor *,
-				    struct afs_volsync *);
-
-extern int afs_rxfs_give_up_callback(struct afs_server *,
-				     struct afs_vnode *);
-
-/* this doesn't appear to work in OpenAFS server */
-extern int afs_rxfs_lookup(struct afs_server *,
-			   struct afs_vnode *,
-			   const char *,
-			   struct afs_vnode *,
-			   struct afs_volsync *);
-
-/* this is apparently mis-implemented in OpenAFS server */
-extern int afs_rxfs_get_root_volume(struct afs_server *,
-				    char *,
-				    size_t *);
-
-
-#endif /* AFS_FSCLIENT_H */
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 900c8bb..1886331 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -19,9 +19,6 @@
 #include <linux/slab.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
-#include "volume.h"
-#include "vnode.h"
-#include "super.h"
 #include "internal.h"
=20
 struct afs_iget_data {
@@ -40,7 +37,7 @@ static int afs_inode_map_status(struct afs_vnode *vno=
de)
 	       vnode->status.type,
 	       vnode->status.nlink,
 	       vnode->status.size,
-	       vnode->status.version,
+	       vnode->status.data_version,
 	       vnode->status.mode);
=20
 	switch (vnode->status.type) {
@@ -78,7 +75,7 @@ static int afs_inode_map_status(struct afs_vnode *vno=
de)
 	if (vnode->status.type =3D=3D AFS_FTYPE_SYMLINK) {
 		afs_mntpt_check_symlink(vnode);
=20
-		if (vnode->flags & AFS_VNODE_MOUNTPOINT) {
+		if (test_bit(AFS_VNODE_MOUNTPOINT, &vnode->flags)) {
 			inode->i_mode	=3D S_IFDIR | vnode->status.mode;
 			inode->i_op	=3D &afs_mntpt_inode_operations;
 			inode->i_fop	=3D &afs_mntpt_file_operations;
@@ -89,25 +86,6 @@ static int afs_inode_map_status(struct afs_vnode *vn=
ode)
 }
=20
 /*
- * attempt to fetch the status of an inode, coelescing multiple simult=
aneous
- * fetches
- */
-static int afs_inode_fetch_status(struct inode *inode)
-{
-	struct afs_vnode *vnode;
-	int ret;
-
-	vnode =3D AFS_FS_I(inode);
-
-	ret =3D afs_vnode_fetch_status(vnode);
-
-	if (ret =3D=3D 0)
-		ret =3D afs_inode_map_status(vnode);
-
-	return ret;
-}
-
-/*
  * iget5() comparator
  */
 static int afs_iget5_test(struct inode *inode, void *opaque)
@@ -137,8 +115,7 @@ static int afs_iget5_set(struct inode *inode, void =
*opaque)
 /*
  * inode retrieval
  */
-inline int afs_iget(struct super_block *sb, struct afs_fid *fid,
-		    struct inode **_inode)
+inline struct inode *afs_iget(struct super_block *sb, struct afs_fid *=
fid)
 {
 	struct afs_iget_data data =3D { .fid =3D *fid };
 	struct afs_super_info *as;
@@ -155,20 +132,18 @@ inline int afs_iget(struct super_block *sb, struc=
t afs_fid *fid,
 			     &data);
 	if (!inode) {
 		_leave(" =3D -ENOMEM");
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 	}
=20
+	_debug("GOT INODE %p { vl=3D%x vn=3D%x, u=3D%x }",
+	       inode, fid->vid, fid->vnode, fid->unique);
+
 	vnode =3D AFS_FS_I(inode);
=20
 	/* deal with an existing inode */
 	if (!(inode->i_state & I_NEW)) {
-		ret =3D afs_vnode_fetch_status(vnode);
-		if (ret =3D=3D 0)
-			*_inode =3D inode;
-		else
-			iput(inode);
-		_leave(" =3D %d", ret);
-		return ret;
+		_leave(" =3D %p", inode);
+		return inode;
 	}
=20
 #ifdef AFS_CACHING_SUPPORT
@@ -181,21 +156,19 @@ inline int afs_iget(struct super_block *sb, struc=
t afs_fid *fid,
 #endif
=20
 	/* okay... it's a new inode */
-	inode->i_flags |=3D S_NOATIME;
-	vnode->flags |=3D AFS_VNODE_CHANGED;
-	ret =3D afs_inode_fetch_status(inode);
-	if (ret<0)
+	set_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
+	ret =3D afs_vnode_fetch_status(vnode);
+	if (ret < 0)
+		goto bad_inode;
+	ret =3D afs_inode_map_status(vnode);
+	if (ret < 0)
 		goto bad_inode;
=20
 	/* success */
+	inode->i_flags |=3D S_NOATIME;
 	unlock_new_inode(inode);
-
-	*_inode =3D inode;
-	_leave(" =3D 0 [CB { v=3D%u x=3D%lu t=3D%u }]",
-	       vnode->cb_version,
-	       vnode->cb_timeout.timo_jif,
-	       vnode->cb_type);
-	return 0;
+	_leave(" =3D %p [CB { v=3D%u t=3D%u }]", inode, vnode->cb_version, vn=
ode->cb_type);
+	return inode;
=20
 	/* failure */
 bad_inode:
@@ -204,7 +177,7 @@ bad_inode:
 	iput(inode);
=20
 	_leave(" =3D %d [bad]", ret);
-	return ret;
+	return ERR_PTR(ret);
 }
=20
 /*
@@ -213,36 +186,13 @@ bad_inode:
 int afs_inode_getattr(struct vfsmount *mnt, struct dentry *dentry,
 		      struct kstat *stat)
 {
-	struct afs_vnode *vnode;
 	struct inode *inode;
-	int ret;
=20
 	inode =3D dentry->d_inode;
=20
 	_enter("{ ino=3D%lu v=3D%lu }", inode->i_ino, inode->i_version);
=20
-	vnode =3D AFS_FS_I(inode);
-
-	ret =3D afs_inode_fetch_status(inode);
-	if (ret =3D=3D -ENOENT) {
-		_leave(" =3D %d [%d %p]",
-		       ret, atomic_read(&dentry->d_count), dentry->d_inode);
-		return ret;
-	} else if (ret < 0) {
-		make_bad_inode(inode);
-		_leave(" =3D %d", ret);
-		return ret;
-	}
-
-	/* transfer attributes from the inode structure to the stat
-	 * structure */
 	generic_fillattr(inode, stat);
-
-	_leave(" =3D 0 CB { v=3D%u x=3D%u t=3D%u }",
-	       vnode->cb_version,
-	       vnode->cb_expiry,
-	       vnode->cb_type);
-
 	return 0;
 }
=20
@@ -260,12 +210,23 @@ void afs_clear_inode(struct inode *inode)
 	       vnode->fid.vnode,
 	       vnode->cb_version,
 	       vnode->cb_expiry,
-	       vnode->cb_type
-	       );
+	       vnode->cb_type);
=20
-	BUG_ON(inode->i_ino !=3D vnode->fid.vnode);
+	_debug("CLEAR INODE %p", inode);
+
+	ASSERTCMP(inode->i_ino, =3D=3D, vnode->fid.vnode);
+
+	afs_give_up_callback(vnode);
+
+	if (vnode->server) {
+		spin_lock(&vnode->server->fs_lock);
+		rb_erase(&vnode->server_rb, &vnode->server->fs_vnodes);
+		spin_unlock(&vnode->server->fs_lock);
+		afs_put_server(vnode->server);
+		vnode->server =3D NULL;
+	}
=20
-	afs_vnode_give_up_callback(vnode);
+	ASSERT(!vnode->cb_promised);
=20
 #ifdef AFS_CACHING_SUPPORT
 	cachefs_relinquish_cookie(vnode->cache, 0);
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index b6dd20a..afc6f0f 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -1,6 +1,6 @@
 /* internal AFS stuff
  *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2002, 2007 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -9,48 +9,321 @@
  * 2 of the License, or (at your option) any later version.
  */
=20
-#ifndef AFS_INTERNAL_H
-#define AFS_INTERNAL_H
-
 #include <linux/compiler.h>
 #include <linux/kernel.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
+#include <linux/skbuff.h>
+#include <linux/rxrpc.h>
+#include "afs.h"
+#include "afs_vl.h"
+
+#define AFS_CELL_MAX_ADDRS 15
+
+struct afs_call;
+
+typedef enum {
+	AFS_VL_NEW,			/* new, uninitialised record */
+	AFS_VL_CREATING,		/* creating record */
+	AFS_VL_VALID,			/* record is pending */
+	AFS_VL_NO_VOLUME,		/* no such volume available */
+	AFS_VL_UPDATING,		/* update in progress */
+	AFS_VL_VOLUME_DELETED,		/* volume was deleted */
+	AFS_VL_UNCERTAIN,		/* uncertain state (update failed) */
+} __attribute__((packed)) afs_vlocation_state_t;
=20
 /*
- * debug tracing
+ * definition of how to wait for the completion of an operation
  */
-#define kenter(FMT, a...)	printk("=3D=3D> %s("FMT")\n",__FUNCTION__ , =
## a)
-#define kleave(FMT, a...)	printk("<=3D=3D %s()"FMT"\n",__FUNCTION__ , =
## a)
-#define kdebug(FMT, a...)	printk(FMT"\n" , ## a)
-#define kproto(FMT, a...)	printk("### "FMT"\n" , ## a)
-#define knet(FMT, a...)		printk(FMT"\n" , ## a)
-
-#ifdef __KDEBUG
-#define _enter(FMT, a...)	kenter(FMT , ## a)
-#define _leave(FMT, a...)	kleave(FMT , ## a)
-#define _debug(FMT, a...)	kdebug(FMT , ## a)
-#define _proto(FMT, a...)	kproto(FMT , ## a)
-#define _net(FMT, a...)		knet(FMT , ## a)
-#else
-#define _enter(FMT, a...)	do { } while(0)
-#define _leave(FMT, a...)	do { } while(0)
-#define _debug(FMT, a...)	do { } while(0)
-#define _proto(FMT, a...)	do { } while(0)
-#define _net(FMT, a...)		do { } while(0)
-#endif
+struct afs_wait_mode {
+	/* RxRPC received message notification */
+	void (*rx_wakeup)(struct afs_call *call);
=20
-static inline void afs_discard_my_signals(void)
-{
-	while (signal_pending(current)) {
-		siginfo_t sinfo;
+	/* synchronous call waiter and call dispatched notification */
+	int (*wait)(struct afs_call *call);
+
+	/* asynchronous call completion */
+	void (*async_complete)(void *reply, int error);
+};
+
+extern const struct afs_wait_mode afs_sync_call;
+extern const struct afs_wait_mode afs_async_call;
+
+/*
+ * a record of an in-progress RxRPC call
+ */
+struct afs_call {
+	const struct afs_call_type *type;	/* type of call */
+	const struct afs_wait_mode *wait_mode;	/* completion wait mode */
+	wait_queue_head_t	waitq;		/* processes awaiting completion */
+	struct work_struct	async_work;	/* asynchronous work processor */
+	struct work_struct	work;		/* actual work processor */
+	struct sk_buff_head	rx_queue;	/* received packets */
+	struct rxrpc_call	*rxcall;	/* RxRPC call handle */
+	struct key		*key;		/* security for this call */
+	struct afs_server	*server;	/* server affected by incoming CM call */
+	void			*request;	/* request data (first part) */
+	void			*request2;	/* request data (second part) */
+	void			*buffer;	/* reply receive buffer */
+	void			*reply;		/* reply buffer (first part) */
+	void			*reply2;	/* reply buffer (second part) */
+	void			*reply3;	/* reply buffer (third part) */
+	enum {					/* call state */
+		AFS_CALL_REQUESTING,	/* request is being sent for outgoing call */
+		AFS_CALL_AWAIT_REPLY,	/* awaiting reply to outgoing call */
+		AFS_CALL_AWAIT_OP_ID,	/* awaiting op ID on incoming call */
+		AFS_CALL_AWAIT_REQUEST,	/* awaiting request data on incoming call */
+		AFS_CALL_REPLYING,	/* replying to incoming call */
+		AFS_CALL_AWAIT_ACK,	/* awaiting final ACK of incoming call */
+		AFS_CALL_COMPLETE,	/* successfully completed */
+		AFS_CALL_BUSY,		/* server was busy */
+		AFS_CALL_ABORTED,	/* call was aborted */
+		AFS_CALL_ERROR,		/* call failed due to error */
+	}			state;
+	int			error;		/* error code */
+	unsigned		request_size;	/* size of request data */
+	unsigned		reply_max;	/* maximum size of reply */
+	unsigned		reply_size;	/* current size of reply */
+	unsigned short		offset;		/* offset into received data store */
+	unsigned char		unmarshall;	/* unmarshalling phase */
+	bool			incoming;	/* T if incoming call */
+	u16			service_id;	/* RxRPC service ID to call */
+	__be16			port;		/* target UDP port */
+	__be32			operation_ID;	/* operation ID for an incoming call */
+	u32			count;		/* count for use in unmarshalling */
+	__be32			tmp;		/* place to extract temporary data */
+};
+
+struct afs_call_type {
+	/* deliver request or reply data to an call
+	 * - returning an error will cause the call to be aborted
+	 */
+	int (*deliver)(struct afs_call *call, struct sk_buff *skb,
+		       bool last);
+
+	/* map an abort code to an error number */
+	int (*abort_to_error)(u32 abort_code);
+
+	/* clean up a call */
+	void (*destructor)(struct afs_call *call);
+};
+
+/*
+ * AFS superblock private data
+ * - there's one superblock per volume
+ */
+struct afs_super_info {
+	struct afs_volume	*volume;	/* volume record */
+	char			rwparent;	/* T if parent is R/W AFS volume */
+};
=20
-		spin_lock_irq(&current->sighand->siglock);
-		dequeue_signal(current,&current->blocked, &sinfo);
-		spin_unlock_irq(&current->sighand->siglock);
-	}
+static inline struct afs_super_info *AFS_FS_S(struct super_block *sb)
+{
+	return sb->s_fs_info;
 }
=20
+extern struct file_system_type afs_fs_type;
+
+/*
+ * entry in the cached cell catalogue
+ */
+struct afs_cache_cell {
+	char			name[64];	/* cell name (padded with NULs) */
+	struct in_addr		vl_servers[15];	/* cached cell VL servers */
+};
+
+/*
+ * AFS cell record
+ */
+struct afs_cell {
+	atomic_t		usage;
+	struct list_head	link;		/* main cell list link */
+	struct list_head	proc_link;	/* /proc cell list link */
+	struct proc_dir_entry	*proc_dir;	/* /proc dir for this cell */
+#ifdef AFS_CACHING_SUPPORT
+	struct cachefs_cookie	*cache;		/* caching cookie */
+#endif
+
+	/* server record management */
+	rwlock_t		servers_lock;	/* active server list lock */
+	struct list_head	servers;	/* active server list */
+
+	/* volume location record management */
+	struct rw_semaphore	vl_sem;		/* volume management serialisation semap=
hore */
+	struct list_head	vl_list;	/* cell's active VL record list */
+	spinlock_t		vl_lock;	/* vl_list lock */
+	unsigned short		vl_naddrs;	/* number of VL servers in addr list */
+	unsigned short		vl_curr_svix;	/* current server index */
+	struct in_addr		vl_addrs[AFS_CELL_MAX_ADDRS];	/* cell VL server addre=
sses */
+
+	char			name[0];	/* cell name - must go last */
+};
+
+/*
+ * entry in the cached volume location catalogue
+ */
+struct afs_cache_vlocation {
+	uint8_t			name[64 + 1];	/* volume name (lowercase, padded with NULs) =
*/
+	uint8_t			nservers;	/* number of entries used in servers[] */
+	uint8_t			vidmask;	/* voltype mask for vid[] */
+	uint8_t			srvtmask[8];	/* voltype masks for servers[] */
+#define AFS_VOL_VTM_RW	0x01 /* R/W version of the volume is available =
(on this server) */
+#define AFS_VOL_VTM_RO	0x02 /* R/O version of the volume is available =
(on this server) */
+#define AFS_VOL_VTM_BAK	0x04 /* backup version of the volume is availa=
ble (on this server) */
+
+	afs_volid_t		vid[3];		/* volume IDs for R/W, R/O and Bak volumes */
+	struct in_addr		servers[8];	/* fileserver addresses */
+	time_t			rtime;		/* last retrieval time */
+};
+
+/*
+ * volume -> vnode hash table entry
+ */
+struct afs_cache_vhash {
+	afs_voltype_t		vtype;		/* which volume variation */
+	uint8_t			hash_bucket;	/* which hash bucket this represents */
+} __attribute__((packed));
+
+/*
+ * AFS volume location record
+ */
+struct afs_vlocation {
+	atomic_t		usage;
+	time_t			time_of_death;	/* time at which put reduced usage to 0 */
+	struct list_head	link;		/* link in cell volume location list */
+	struct list_head	grave;		/* link in master graveyard list */
+	struct list_head	update;		/* link in master update list */
+	struct afs_cell		*cell;		/* cell to which volume belongs */
+#ifdef AFS_CACHING_SUPPORT
+	struct cachefs_cookie	*cache;		/* caching cookie */
+#endif
+	struct afs_cache_vlocation vldb;	/* volume information DB record */
+	struct afs_volume	*vols[3];	/* volume access record pointer (index by=
 type) */
+	wait_queue_head_t	waitq;		/* status change waitqueue */
+	time_t			update_at;	/* time at which record should be updated */
+	rwlock_t		lock;		/* access lock */
+	afs_vlocation_state_t	state;		/* volume location state */
+	unsigned short		upd_rej_cnt;	/* ENOMEDIUM count during update */
+	unsigned short		upd_busy_cnt;	/* EBUSY count during update */
+	bool			valid;		/* T if valid */
+};
+
+/*
+ * AFS fileserver record
+ */
+struct afs_server {
+	atomic_t		usage;
+	time_t			time_of_death;	/* time at which put reduced usage to 0 */
+	struct in_addr		addr;		/* server address */
+	struct afs_cell		*cell;		/* cell in which server resides */
+	struct list_head	link;		/* link in cell's server list */
+	struct list_head	grave;		/* link in master graveyard list */
+	struct rb_node		master_rb;	/* link in master by-addr tree */
+	struct rw_semaphore	sem;		/* access lock */
+
+	/* file service access */
+	struct rb_root		fs_vnodes;	/* vnodes backed by this server (ordered b=
y FID) */
+	unsigned long		fs_act_jif;	/* time at which last activity occurred */
+	unsigned long		fs_dead_jif;	/* time at which no longer to be consider=
ed dead */
+	spinlock_t		fs_lock;	/* access lock */
+	int			fs_state;      	/* 0 or reason FS currently marked dead (-errno=
) */
+
+	/* callback promise management */
+	struct rb_root		cb_promises;	/* vnode expiration list (ordered earlie=
st first) */
+	struct delayed_work	cb_updater;	/* callback updater */
+	struct delayed_work	cb_break_work;	/* collected break dispatcher */
+	wait_queue_head_t	cb_break_waitq;	/* space available in cb_break wait=
queue */
+	spinlock_t		cb_lock;	/* access lock */
+	struct afs_callback	cb_break[64];	/* ring of callbacks awaiting break=
ing */
+	atomic_t		cb_break_n;	/* number of pending breaks */
+	u8			cb_break_head;	/* head of callback breaking ring */
+	u8			cb_break_tail;	/* tail of callback breaking ring */
+};
+
+/*
+ * AFS volume access record
+ */
+struct afs_volume {
+	atomic_t		usage;
+	struct afs_cell		*cell;		/* cell to which belongs (unrefd ptr) */
+	struct afs_vlocation	*vlocation;	/* volume location */
+#ifdef AFS_CACHING_SUPPORT
+	struct cachefs_cookie	*cache;		/* caching cookie */
+#endif
+	afs_volid_t		vid;		/* volume ID */
+	afs_voltype_t		type;		/* type of volume */
+	char			type_force;	/* force volume type (suppress R/O -> R/W) */
+	unsigned short		nservers;	/* number of server slots filled */
+	unsigned short		rjservers;	/* number of servers discarded due to -ENO=
MEDIUM */
+	struct afs_server	*servers[8];	/* servers on which volume resides (or=
dered) */
+	struct rw_semaphore	server_sem;	/* lock for accessing current server =
*/
+};
+
+/*
+ * vnode catalogue entry
+ */
+struct afs_cache_vnode {
+	afs_vnodeid_t		vnode_id;	/* vnode ID */
+	unsigned		vnode_unique;	/* vnode ID uniquifier */
+	afs_dataversion_t	data_version;	/* data version */
+};
+
+/*
+ * AFS inode private data
+ */
+struct afs_vnode {
+	struct inode		vfs_inode;	/* the VFS's inode record */
+
+	struct afs_volume	*volume;	/* volume on which vnode resides */
+	struct afs_server	*server;	/* server currently supplying this file */
+	struct afs_fid		fid;		/* the file identifier for this inode */
+	struct afs_file_status	status;		/* AFS status info for this file */
+#ifdef AFS_CACHING_SUPPORT
+	struct cachefs_cookie	*cache;		/* caching cookie */
+#endif
+
+	wait_queue_head_t	update_waitq;	/* status fetch waitqueue */
+	unsigned		update_cnt;	/* number of outstanding ops that will update t=
he
+						 * status */
+	spinlock_t		lock;		/* waitqueue/flags lock */
+	unsigned long		flags;
+#define AFS_VNODE_CB_BROKEN	0		/* set if vnode's callback was broken *=
/
+#define AFS_VNODE_CHANGED	1		/* set if vnode's metadata changed */
+#define AFS_VNODE_MODIFIED	2		/* set if vnode's data modified */
+#define AFS_VNODE_ZAP_DATA	3		/* set if vnode's data should be invalid=
ated */
+#define AFS_VNODE_DELETED	4		/* set if vnode deleted on server */
+#define AFS_VNODE_MOUNTPOINT	5		/* set if vnode is a mountpoint symlin=
k */
+#define AFS_VNODE_DIR_CHANGED	6		/* set if vnode's parent dir metadata=
 changed */
+#define AFS_VNODE_DIR_MODIFIED	7		/* set if vnode's parent dir data mo=
dified */
+
+	/* outstanding callback notification on this file */
+	struct rb_node		server_rb;	/* link in server->fs_vnodes */
+	struct rb_node		cb_promise;	/* link in server->cb_promises */
+	struct work_struct	cb_broken_work;	/* work to be done on callback bre=
ak */
+	struct mutex		cb_broken_lock;	/* lock against multiple attempts to fi=
x break */
+//	struct list_head	cb_hash_link;	/* link in master callback hash */
+	time_t			cb_expires;	/* time at which callback expires */
+	time_t			cb_expires_at;	/* time used to order cb_promise */
+	unsigned		cb_version;	/* callback version */
+	unsigned		cb_expiry;	/* callback expiry time */
+	afs_callback_type_t	cb_type;	/* type of callback */
+	bool			cb_promised;	/* true if promise still holds */
+};
+
+/*********************************************************************=
********/
+/*
+ * callback.c
+ */
+extern void afs_init_callback_state(struct afs_server *);
+extern void afs_broken_callback_work(struct work_struct *);
+extern void afs_break_callbacks(struct afs_server *, size_t,
+				struct afs_callback[]);
+extern void afs_give_up_callback(struct afs_vnode *);
+extern void afs_dispatch_give_up_callbacks(struct work_struct *);
+extern void afs_flush_callback_breaks(struct afs_server *);
+extern int __init afs_callback_update_init(void);
+extern void __exit afs_callback_update_kill(void);
+
 /*
  * cell.c
  */
@@ -60,6 +333,19 @@ extern struct list_head afs_proc_cells;
 extern struct cachefs_index_def afs_cache_cell_index_def;
 #endif
=20
+#define afs_get_cell(C) do { atomic_inc(&(C)->usage); } while(0)
+extern int afs_cell_init(char *);
+extern struct afs_cell *afs_cell_create(const char *, char *);
+extern struct afs_cell *afs_cell_lookup(const char *, unsigned);
+extern struct afs_cell *afs_grab_cell(struct afs_cell *);
+extern void afs_put_cell(struct afs_cell *);
+extern void afs_cell_purge(void);
+
+/*
+ * cmservice.c
+ */
+extern bool afs_cm_incoming_call(struct afs_call *);
+
 /*
  * dir.c
  */
@@ -77,9 +363,22 @@ extern int afs_cache_get_page_cookie(struct page *,=
 struct cachefs_page **);
 #endif
=20
 /*
+ * fsclient.c
+ */
+extern int afs_fs_fetch_file_status(struct afs_server *,
+				    struct afs_vnode *,
+				    struct afs_volsync *,
+				    const struct afs_wait_mode *);
+extern int afs_fs_give_up_callbacks(struct afs_server *,
+				    const struct afs_wait_mode *);
+extern int afs_fs_fetch_data(struct afs_server *, struct afs_vnode *, =
off_t,
+			     size_t, struct page *, struct afs_volsync *,
+			     const struct afs_wait_mode *);
+
+/*
  * inode.c
  */
-extern int afs_iget(struct super_block *, struct afs_fid *, struct ino=
de **);
+extern struct inode *afs_iget(struct super_block *, struct afs_fid *);
 extern int afs_inode_getattr(struct vfsmount *, struct dentry *,
 			     struct kstat *);
 extern void afs_clear_inode(struct inode *);
@@ -92,15 +391,20 @@ extern struct cachefs_netfs afs_cache_netfs;
 #endif
=20
 /*
+ * misc.c
+ */
+extern int afs_abort_to_error(u32);
+
+/*
  * mntpt.c
  */
 extern const struct inode_operations afs_mntpt_inode_operations;
 extern const struct file_operations afs_mntpt_file_operations;
-extern struct afs_timer afs_mntpt_expiry_timer;
-extern struct afs_timer_ops afs_mntpt_expiry_timer_ops;
 extern unsigned long afs_mntpt_expiry_timeout;
=20
 extern int afs_mntpt_check_symlink(struct afs_vnode *);
+extern void afs_mntpt_kill_timer(void);
+extern void afs_umount_begin(struct vfsmount *, int);
=20
 /*
  * super.c
@@ -108,16 +412,6 @@ extern int afs_mntpt_check_symlink(struct afs_vnod=
e *);
 extern int afs_fs_init(void);
 extern void afs_fs_exit(void);
=20
-#define AFS_CB_HASH_COUNT (PAGE_SIZE / sizeof(struct list_head))
-
-extern struct list_head afs_cb_hash_tbl[];
-extern spinlock_t afs_cb_hash_lock;
-
-#define afs_cb_hash(SRV, FID)						\
-	afs_cb_hash_tbl[((unsigned long)(SRV) +				\
-			 (FID)->vid + (FID)->vnode + (FID)->unique) &	\
-			(AFS_CB_HASH_COUNT - 1)]
-
 /*
  * proc.c
  */
@@ -126,4 +420,217 @@ extern void afs_proc_cleanup(void);
 extern int afs_proc_cell_setup(struct afs_cell *);
 extern void afs_proc_cell_remove(struct afs_cell *);
=20
-#endif /* AFS_INTERNAL_H */
+/*
+ * rxrpc.c
+ */
+extern int afs_open_socket(void);
+extern void afs_close_socket(void);
+extern int afs_make_call(struct in_addr *, struct afs_call *, gfp_t,
+			 const struct afs_wait_mode *);
+extern struct afs_call *afs_alloc_flat_call(const struct afs_call_type=
 *,
+					    size_t, size_t);
+extern void afs_flat_call_destructor(struct afs_call *);
+extern void afs_transfer_reply(struct afs_call *, struct sk_buff *);
+extern void afs_send_empty_reply(struct afs_call *);
+extern int afs_extract_data(struct afs_call *, struct sk_buff *, bool,=
 void *,
+			    size_t);
+
+/*
+ * server.c
+ */
+extern spinlock_t afs_server_peer_lock;
+
+#define afs_get_server(S) do { atomic_inc(&(S)->usage); } while(0)
+
+extern struct afs_server *afs_lookup_server(struct afs_cell *,
+					    const struct in_addr *);
+extern struct afs_server *afs_find_server(const struct in_addr *);
+extern void afs_put_server(struct afs_server *);
+extern void __exit afs_purge_servers(void);
+
+/*
+ * vlclient.c
+ */
+#ifdef AFS_CACHING_SUPPORT
+extern struct cachefs_index_def afs_vlocation_cache_index_def;
+#endif
+
+extern int afs_vl_get_entry_by_name(struct in_addr *, const char *,
+				    struct afs_cache_vlocation *,
+				    const struct afs_wait_mode *);
+extern int afs_vl_get_entry_by_id(struct in_addr *, afs_volid_t, afs_v=
oltype_t,
+				  struct afs_cache_vlocation *,
+				  const struct afs_wait_mode *);
+
+/*
+ * vlocation.c
+ */
+#define afs_get_vlocation(V) do { atomic_inc(&(V)->usage); } while(0)
+
+extern int __init afs_vlocation_update_init(void);
+extern struct afs_vlocation *afs_vlocation_lookup(struct afs_cell *,
+						  const char *, size_t);
+extern void afs_put_vlocation(struct afs_vlocation *);
+extern void __exit afs_vlocation_purge(void);
+
+/*
+ * vnode.c
+ */
+#ifdef AFS_CACHING_SUPPORT
+extern struct cachefs_index_def afs_vnode_cache_index_def;
+#endif
+
+extern struct afs_timer_ops afs_vnode_cb_timed_out_ops;
+
+static inline struct afs_vnode *AFS_FS_I(struct inode *inode)
+{
+	return container_of(inode, struct afs_vnode, vfs_inode);
+}
+
+static inline struct inode *AFS_VNODE_TO_I(struct afs_vnode *vnode)
+{
+	return &vnode->vfs_inode;
+}
+
+extern int afs_vnode_fetch_status(struct afs_vnode *);
+extern int afs_vnode_fetch_data(struct afs_vnode *vnode, off_t, size_t=
,
+				struct page *);
+
+/*
+ * volume.c
+ */
+#ifdef AFS_CACHING_SUPPORT
+extern struct cachefs_index_def afs_volume_cache_index_def;
+#endif
+
+#define afs_get_volume(V) do { atomic_inc(&(V)->usage); } while(0)
+
+extern void afs_put_volume(struct afs_volume *);
+extern struct afs_volume *afs_volume_lookup(const char *, struct afs_c=
ell *,
+					    int);
+extern struct afs_server *afs_volume_pick_fileserver(struct afs_vnode =
*);
+extern int afs_volume_release_fileserver(struct afs_vnode *,
+					 struct afs_server *, int);
+
+/*********************************************************************=
********/
+/*
+ * debug tracing
+ */
+extern unsigned afs_debug;
+
+#define dbgprintk(FMT,...) \
+	printk("[%x%-6.6s] "FMT"\n", smp_processor_id(), current->comm ,##__V=
A_ARGS__)
+
+/* make sure we maintain the format strings, even when debugging is di=
sabled */
+static inline __attribute__((format(printf,1,2)))
+void _dbprintk(const char *fmt, ...)
+{
+}
+
+#define kenter(FMT,...)	dbgprintk("=3D=3D> %s("FMT")",__FUNCTION__ ,##=
__VA_ARGS__)
+#define kleave(FMT,...)	dbgprintk("<=3D=3D %s()"FMT"",__FUNCTION__ ,##=
__VA_ARGS__)
+#define kdebug(FMT,...)	dbgprintk("    "FMT ,##__VA_ARGS__)
+
+
+#if defined(__KDEBUG)
+#define _enter(FMT,...)	kenter(FMT,##__VA_ARGS__)
+#define _leave(FMT,...)	kleave(FMT,##__VA_ARGS__)
+#define _debug(FMT,...)	kdebug(FMT,##__VA_ARGS__)
+
+#elif defined(CONFIG_AFS_DEBUG)
+#define AFS_DEBUG_KENTER	0x01
+#define AFS_DEBUG_KLEAVE	0x02
+#define AFS_DEBUG_KDEBUG	0x04
+
+#define _enter(FMT,...)					\
+do {							\
+	if (unlikely(afs_debug & AFS_DEBUG_KENTER))	\
+		kenter(FMT,##__VA_ARGS__);		\
+} while (0)
+
+#define _leave(FMT,...)					\
+do {							\
+	if (unlikely(afs_debug & AFS_DEBUG_KLEAVE))	\
+		kleave(FMT,##__VA_ARGS__);		\
+} while (0)
+
+#define _debug(FMT,...)					\
+do {							\
+	if (unlikely(afs_debug & AFS_DEBUG_KDEBUG))	\
+		kdebug(FMT,##__VA_ARGS__);		\
+} while (0)
+
+#else
+#define _enter(FMT,...)	_dbprintk("=3D=3D> %s("FMT")",__FUNCTION__ ,##=
__VA_ARGS__)
+#define _leave(FMT,...)	_dbprintk("<=3D=3D %s()"FMT"",__FUNCTION__ ,##=
__VA_ARGS__)
+#define _debug(FMT,...)	_dbprintk("    "FMT ,##__VA_ARGS__)
+#endif
+
+/*
+ * debug assertion checking
+ */
+#if 1 // defined(__KDEBUGALL)
+
+#define ASSERT(X)						\
+do {								\
+	if (unlikely(!(X))) {					\
+		printk(KERN_ERR "\n");				\
+		printk(KERN_ERR "AFS: Assertion failed\n");	\
+		BUG();						\
+	}							\
+} while(0)
+
+#define ASSERTCMP(X, OP, Y)						\
+do {									\
+	if (unlikely(!((X) OP (Y)))) {					\
+		printk(KERN_ERR "\n");					\
+		printk(KERN_ERR "AFS: Assertion failed\n");		\
+		printk(KERN_ERR "%lu " #OP " %lu is false\n",		\
+		       (unsigned long)(X), (unsigned long)(Y));		\
+		printk(KERN_ERR "0x%lx " #OP " 0x%lx is false\n",	\
+		       (unsigned long)(X), (unsigned long)(Y));		\
+		BUG();							\
+	}								\
+} while(0)
+
+#define ASSERTIF(C, X)						\
+do {								\
+	if (unlikely((C) && !(X))) {				\
+		printk(KERN_ERR "\n");				\
+		printk(KERN_ERR "AFS: Assertion failed\n");	\
+		BUG();						\
+	}							\
+} while(0)
+
+#define ASSERTIFCMP(C, X, OP, Y)					\
+do {									\
+	if (unlikely((C) && !((X) OP (Y)))) {				\
+		printk(KERN_ERR "\n");					\
+		printk(KERN_ERR "AFS: Assertion failed\n");		\
+		printk(KERN_ERR "%lu " #OP " %lu is false\n",		\
+		       (unsigned long)(X), (unsigned long)(Y));		\
+		printk(KERN_ERR "0x%lx " #OP " 0x%lx is false\n",	\
+		       (unsigned long)(X), (unsigned long)(Y));		\
+		BUG();							\
+	}								\
+} while(0)
+
+#else
+
+#define ASSERT(X)				\
+do {						\
+} while(0)
+
+#define ASSERTCMP(X, OP, Y)			\
+do {						\
+} while(0)
+
+#define ASSERTIF(C, X)				\
+do {						\
+} while(0)
+
+#define ASSERTIFCMP(C, X, OP, Y)		\
+do {						\
+} while(0)
+
+#endif /* __KDEBUGALL */
diff --git a/fs/afs/kafsasyncd.c b/fs/afs/kafsasyncd.c
deleted file mode 100644
index 8ca01c2..0000000
--- a/fs/afs/kafsasyncd.c
+++ /dev/null
@@ -1,247 +0,0 @@
-/* AFS asynchronous operation daemon
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- *
- *
- * The AFS async daemon is used to the following:
- * - probe "dead" servers to see whether they've come back to life yet=
=2E
- * - probe "live" servers that we haven't talked to for a while to see=
 if they are better
- *   candidates for serving than what we're currently using
- * - poll volume location servers to keep up to date volume location l=
ists
- */
-
-#include <linux/module.h>
-#include <linux/init.h>
-#include <linux/sched.h>
-#include <linux/completion.h>
-#include <linux/freezer.h>
-#include "cell.h"
-#include "server.h"
-#include "volume.h"
-#include "kafsasyncd.h"
-#include "kafstimod.h"
-#include <rxrpc/call.h>
-#include <asm/errno.h>
-#include "internal.h"
-
-static DECLARE_COMPLETION(kafsasyncd_alive);
-static DECLARE_COMPLETION(kafsasyncd_dead);
-static DECLARE_WAIT_QUEUE_HEAD(kafsasyncd_sleepq);
-static struct task_struct *kafsasyncd_task;
-static int kafsasyncd_die;
-
-static int kafsasyncd(void *arg);
-
-static LIST_HEAD(kafsasyncd_async_attnq);
-static LIST_HEAD(kafsasyncd_async_busyq);
-static DEFINE_SPINLOCK(kafsasyncd_async_lock);
-
-static void kafsasyncd_null_call_attn_func(struct rxrpc_call *call)
-{
-}
-
-static void kafsasyncd_null_call_error_func(struct rxrpc_call *call)
-{
-}
-
-/*
- * start the async daemon
- */
-int afs_kafsasyncd_start(void)
-{
-	int ret;
-
-	ret =3D kernel_thread(kafsasyncd, NULL, 0);
-	if (ret < 0)
-		return ret;
-
-	wait_for_completion(&kafsasyncd_alive);
-
-	return ret;
-}
-
-/*
- * stop the async daemon
- */
-void afs_kafsasyncd_stop(void)
-{
-	/* get rid of my daemon */
-	kafsasyncd_die =3D 1;
-	wake_up(&kafsasyncd_sleepq);
-	wait_for_completion(&kafsasyncd_dead);
-}
-
-/*
- * probing daemon
- */
-static int kafsasyncd(void *arg)
-{
-	struct afs_async_op *op;
-	int die;
-
-	DECLARE_WAITQUEUE(myself, current);
-
-	kafsasyncd_task =3D current;
-
-	printk("kAFS: Started kafsasyncd %d\n", current->pid);
-
-	daemonize("kafsasyncd");
-
-	complete(&kafsasyncd_alive);
-
-	/* loop around looking for things to attend to */
-	do {
-		set_current_state(TASK_INTERRUPTIBLE);
-		add_wait_queue(&kafsasyncd_sleepq, &myself);
-
-		for (;;) {
-			if (!list_empty(&kafsasyncd_async_attnq) ||
-			    signal_pending(current) ||
-			    kafsasyncd_die)
-				break;
-
-			schedule();
-			set_current_state(TASK_INTERRUPTIBLE);
-		}
-
-		remove_wait_queue(&kafsasyncd_sleepq, &myself);
-		set_current_state(TASK_RUNNING);
-
-		try_to_freeze();
-
-		/* discard pending signals */
-		afs_discard_my_signals();
-
-		die =3D kafsasyncd_die;
-
-		/* deal with the next asynchronous operation requiring
-		 * attention */
-		if (!list_empty(&kafsasyncd_async_attnq)) {
-			struct afs_async_op *op;
-
-			_debug("@@@ Begin Asynchronous Operation");
-
-			op =3D NULL;
-			spin_lock(&kafsasyncd_async_lock);
-
-			if (!list_empty(&kafsasyncd_async_attnq)) {
-				op =3D list_entry(kafsasyncd_async_attnq.next,
-						struct afs_async_op, link);
-				list_move_tail(&op->link,
-					      &kafsasyncd_async_busyq);
-			}
-
-			spin_unlock(&kafsasyncd_async_lock);
-
-			_debug("@@@ Operation %p {%p}\n",
-			       op, op ? op->ops : NULL);
-
-			if (op)
-				op->ops->attend(op);
-
-			_debug("@@@ End Asynchronous Operation");
-		}
-
-	} while(!die);
-
-	/* need to kill all outstanding asynchronous operations before
-	 * exiting */
-	kafsasyncd_task =3D NULL;
-	spin_lock(&kafsasyncd_async_lock);
-
-	/* fold the busy and attention queues together */
-	list_splice_init(&kafsasyncd_async_busyq,
-			 &kafsasyncd_async_attnq);
-
-	/* dequeue kafsasyncd from all their wait queues */
-	list_for_each_entry(op, &kafsasyncd_async_attnq, link) {
-		op->call->app_attn_func =3D kafsasyncd_null_call_attn_func;
-		op->call->app_error_func =3D kafsasyncd_null_call_error_func;
-		remove_wait_queue(&op->call->waitq, &op->waiter);
-	}
-
-	spin_unlock(&kafsasyncd_async_lock);
-
-	/* abort all the operations */
-	while (!list_empty(&kafsasyncd_async_attnq)) {
-		op =3D list_entry(kafsasyncd_async_attnq.next, struct afs_async_op, =
link);
-		list_del_init(&op->link);
-
-		rxrpc_call_abort(op->call, -EIO);
-		rxrpc_put_call(op->call);
-		op->call =3D NULL;
-
-		op->ops->discard(op);
-	}
-
-	/* and that's all */
-	_leave("");
-	complete_and_exit(&kafsasyncd_dead, 0);
-}
-
-/*
- * begin an operation
- * - place operation on busy queue
- */
-void afs_kafsasyncd_begin_op(struct afs_async_op *op)
-{
-	_enter("");
-
-	spin_lock(&kafsasyncd_async_lock);
-
-	init_waitqueue_entry(&op->waiter, kafsasyncd_task);
-	add_wait_queue(&op->call->waitq, &op->waiter);
-
-	list_move_tail(&op->link, &kafsasyncd_async_busyq);
-
-	spin_unlock(&kafsasyncd_async_lock);
-
-	_leave("");
-}
-
-/*
- * request attention for an operation
- * - move to attention queue
- */
-void afs_kafsasyncd_attend_op(struct afs_async_op *op)
-{
-	_enter("");
-
-	spin_lock(&kafsasyncd_async_lock);
-
-	list_move_tail(&op->link, &kafsasyncd_async_attnq);
-
-	spin_unlock(&kafsasyncd_async_lock);
-
-	wake_up(&kafsasyncd_sleepq);
-
-	_leave("");
-}
-
-/*
- * terminate an operation
- * - remove from either queue
- */
-void afs_kafsasyncd_terminate_op(struct afs_async_op *op)
-{
-	_enter("");
-
-	spin_lock(&kafsasyncd_async_lock);
-
-	if (!list_empty(&op->link)) {
-		list_del_init(&op->link);
-		remove_wait_queue(&op->call->waitq, &op->waiter);
-	}
-
-	spin_unlock(&kafsasyncd_async_lock);
-
-	wake_up(&kafsasyncd_sleepq);
-
-	_leave("");
-}
diff --git a/fs/afs/kafsasyncd.h b/fs/afs/kafsasyncd.h
deleted file mode 100644
index 1273eb5..0000000
--- a/fs/afs/kafsasyncd.h
+++ /dev/null
@@ -1,50 +0,0 @@
-/* AFS asynchronous operation daemon
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef AFS_KAFSASYNCD_H
-#define AFS_KAFSASYNCD_H
-
-#include "types.h"
-
-struct afs_async_op;
-
-struct afs_async_op_ops {
-	void (*attend)(struct afs_async_op *);
-	void (*discard)(struct afs_async_op *);
-};
-
-/*
- * asynchronous operation record
- */
-struct afs_async_op {
-	struct list_head		link;
-	struct afs_server		*server;	/* server being contacted */
-	struct rxrpc_call		*call;		/* RxRPC call performing op */
-	wait_queue_t			waiter;		/* wait queue for kafsasyncd */
-	const struct afs_async_op_ops	*ops;		/* operations */
-};
-
-static inline void afs_async_op_init(struct afs_async_op *op,
-				     const struct afs_async_op_ops *ops)
-{
-	INIT_LIST_HEAD(&op->link);
-	op->call =3D NULL;
-	op->ops =3D ops;
-}
-
-extern int afs_kafsasyncd_start(void);
-extern void afs_kafsasyncd_stop(void);
-
-extern void afs_kafsasyncd_begin_op(struct afs_async_op *);
-extern void afs_kafsasyncd_attend_op(struct afs_async_op *);
-extern void afs_kafsasyncd_terminate_op(struct afs_async_op *);
-
-#endif /* AFS_KAFSASYNCD_H */
diff --git a/fs/afs/kafstimod.c b/fs/afs/kafstimod.c
deleted file mode 100644
index 3526dcc..0000000
--- a/fs/afs/kafstimod.c
+++ /dev/null
@@ -1,194 +0,0 @@
-/* AFS timeout daemon
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#include <linux/module.h>
-#include <linux/init.h>
-#include <linux/sched.h>
-#include <linux/completion.h>
-#include <linux/freezer.h>
-#include "cell.h"
-#include "volume.h"
-#include "kafstimod.h"
-#include <asm/errno.h>
-#include "internal.h"
-
-static DECLARE_COMPLETION(kafstimod_alive);
-static DECLARE_COMPLETION(kafstimod_dead);
-static DECLARE_WAIT_QUEUE_HEAD(kafstimod_sleepq);
-static int kafstimod_die;
-
-static LIST_HEAD(kafstimod_list);
-static DEFINE_SPINLOCK(kafstimod_lock);
-
-static int kafstimod(void *arg);
-
-/*
- * start the timeout daemon
- */
-int afs_kafstimod_start(void)
-{
-	int ret;
-
-	ret =3D kernel_thread(kafstimod, NULL, 0);
-	if (ret < 0)
-		return ret;
-
-	wait_for_completion(&kafstimod_alive);
-
-	return ret;
-}
-
-/*
- * stop the timeout daemon
- */
-void afs_kafstimod_stop(void)
-{
-	/* get rid of my daemon */
-	kafstimod_die =3D 1;
-	wake_up(&kafstimod_sleepq);
-	wait_for_completion(&kafstimod_dead);
-}
-
-/*
- * timeout processing daemon
- */
-static int kafstimod(void *arg)
-{
-	struct afs_timer *timer;
-
-	DECLARE_WAITQUEUE(myself, current);
-
-	printk("kAFS: Started kafstimod %d\n", current->pid);
-
-	daemonize("kafstimod");
-
-	complete(&kafstimod_alive);
-
-	/* loop around looking for things to attend to */
-loop:
-	set_current_state(TASK_INTERRUPTIBLE);
-	add_wait_queue(&kafstimod_sleepq, &myself);
-
-	for (;;) {
-		unsigned long jif;
-		signed long timeout;
-
-		/* deal with the server being asked to die */
-		if (kafstimod_die) {
-			remove_wait_queue(&kafstimod_sleepq, &myself);
-			_leave("");
-			complete_and_exit(&kafstimod_dead, 0);
-		}
-
-		try_to_freeze();
-
-		/* discard pending signals */
-		afs_discard_my_signals();
-
-		/* work out the time to elapse before the next event */
-		spin_lock(&kafstimod_lock);
-		if (list_empty(&kafstimod_list)) {
-			timeout =3D MAX_SCHEDULE_TIMEOUT;
-		} else {
-			timer =3D list_entry(kafstimod_list.next,
-					   struct afs_timer, link);
-			timeout =3D timer->timo_jif;
-			jif =3D jiffies;
-
-			if (time_before_eq((unsigned long) timeout, jif))
-				goto immediate;
-			timeout =3D (long) timeout - (long) jiffies;
-		}
-		spin_unlock(&kafstimod_lock);
-
-		schedule_timeout(timeout);
-
-		set_current_state(TASK_INTERRUPTIBLE);
-	}
-
-	/* the thing on the front of the queue needs processing
-	 * - we come here with the lock held and timer pointing to the expire=
d
-	 *   entry
-	 */
-immediate:
-	remove_wait_queue(&kafstimod_sleepq, &myself);
-	set_current_state(TASK_RUNNING);
-
-	_debug("@@@ Begin Timeout of %p", timer);
-
-	/* dequeue the timer */
-	list_del_init(&timer->link);
-	spin_unlock(&kafstimod_lock);
-
-	/* call the timeout function */
-	timer->ops->timed_out(timer);
-
-	_debug("@@@ End Timeout");
-	goto loop;
-}
-
-/*
- * (re-)queue a timer
- */
-void afs_kafstimod_add_timer(struct afs_timer *timer, unsigned long ti=
meout)
-{
-	struct afs_timer *ptimer;
-	struct list_head *_p;
-
-	_enter("%p,%lu", timer, timeout);
-
-	spin_lock(&kafstimod_lock);
-
-	list_del(&timer->link);
-
-	/* the timer was deferred or reset - put it back in the queue at the
-	 * right place */
-	timer->timo_jif =3D jiffies + timeout;
-
-	list_for_each(_p, &kafstimod_list) {
-		ptimer =3D list_entry(_p, struct afs_timer, link);
-		if (time_before(timer->timo_jif, ptimer->timo_jif))
-			break;
-	}
-
-	list_add_tail(&timer->link, _p); /* insert before stopping point */
-
-	spin_unlock(&kafstimod_lock);
-
-	wake_up(&kafstimod_sleepq);
-
-	_leave("");
-}
-
-/*
- * dequeue a timer
- * - returns 0 if the timer was deleted or -ENOENT if it wasn't queued
- */
-int afs_kafstimod_del_timer(struct afs_timer *timer)
-{
-	int ret =3D 0;
-
-	_enter("%p", timer);
-
-	spin_lock(&kafstimod_lock);
-
-	if (list_empty(&timer->link))
-		ret =3D -ENOENT;
-	else
-		list_del_init(&timer->link);
-
-	spin_unlock(&kafstimod_lock);
-
-	wake_up(&kafstimod_sleepq);
-
-	_leave(" =3D %d", ret);
-	return ret;
-}
diff --git a/fs/afs/kafstimod.h b/fs/afs/kafstimod.h
deleted file mode 100644
index 0d39bec..0000000
--- a/fs/afs/kafstimod.h
+++ /dev/null
@@ -1,45 +0,0 @@
-/* AFS timeout daemon
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef AFS_KAFSTIMOD_H
-#define AFS_KAFSTIMOD_H
-
-#include "types.h"
-
-struct afs_timer;
-
-struct afs_timer_ops {
-	/* called when the front of the timer queue has timed out */
-	void (*timed_out)(struct afs_timer *);
-};
-
-/*
- * AFS timer/timeout record
- */
-struct afs_timer {
-	struct list_head		link;		/* link in timer queue */
-	unsigned long			timo_jif;	/* timeout time */
-	const struct afs_timer_ops	*ops;		/* timeout expiry function */
-};
-
-static inline void afs_timer_init(struct afs_timer *timer,
-				  const struct afs_timer_ops *ops)
-{
-	INIT_LIST_HEAD(&timer->link);
-	timer->ops =3D ops;
-}
-
-extern int afs_kafstimod_start(void);
-extern void afs_kafstimod_stop(void);
-extern void afs_kafstimod_add_timer(struct afs_timer *, unsigned long)=
;
-extern int afs_kafstimod_del_timer(struct afs_timer *);
-
-#endif /* AFS_KAFSTIMOD_H */
diff --git a/fs/afs/main.c b/fs/afs/main.c
index 5bf39f6..0cf1b02 100644
--- a/fs/afs/main.c
+++ b/fs/afs/main.c
@@ -13,43 +13,21 @@
 #include <linux/moduleparam.h>
 #include <linux/init.h>
 #include <linux/completion.h>
-#include <rxrpc/rxrpc.h>
-#include <rxrpc/transport.h>
-#include <rxrpc/call.h>
-#include <rxrpc/peer.h>
-#include "cache.h"
-#include "cell.h"
-#include "server.h"
-#include "fsclient.h"
-#include "cmservice.h"
-#include "kafstimod.h"
-#include "kafsasyncd.h"
 #include "internal.h"
=20
-struct rxrpc_transport *afs_transport;
-
-static int afs_adding_peer(struct rxrpc_peer *peer);
-static void afs_discarding_peer(struct rxrpc_peer *peer);
-
-
 MODULE_DESCRIPTION("AFS Client File System");
 MODULE_AUTHOR("Red Hat, Inc.");
 MODULE_LICENSE("GPL");
=20
+unsigned afs_debug;
+module_param_named(debug, afs_debug, uint, S_IWUSR | S_IRUGO);
+MODULE_PARM_DESC(afs_debug, "AFS debugging mask");
+
 static char *rootcell;
=20
 module_param(rootcell, charp, 0);
 MODULE_PARM_DESC(rootcell, "root AFS cell name and VL server IP addr l=
ist");
=20
-
-static struct rxrpc_peer_ops afs_peer_ops =3D {
-	.adding		=3D afs_adding_peer,
-	.discarding	=3D afs_discarding_peer,
-};
-
-struct list_head afs_cb_hash_tbl[AFS_CB_HASH_COUNT];
-DEFINE_SPINLOCK(afs_cb_hash_lock);
-
 #ifdef AFS_CACHING_SUPPORT
 static struct cachefs_netfs_operations afs_cache_ops =3D {
 	.get_page_cookie	=3D afs_cache_get_page_cookie,
@@ -67,15 +45,10 @@ struct cachefs_netfs afs_cache_netfs =3D {
  */
 static int __init afs_init(void)
 {
-	int loop, ret;
+	int ret;
=20
 	printk(KERN_INFO "kAFS: Red Hat AFS client v0.1 registering.\n");
=20
-	/* initialise the callback hash table */
-	spin_lock_init(&afs_cb_hash_lock);
-	for (loop =3D AFS_CB_HASH_COUNT - 1; loop >=3D 0; loop--)
-		INIT_LIST_HEAD(&afs_cb_hash_tbl[loop]);
-
 	/* register the /proc stuff */
 	ret =3D afs_proc_init();
 	if (ret < 0)
@@ -94,22 +67,18 @@ static int __init afs_init(void)
 	if (ret < 0)
 		goto error_cell_init;
=20
-	/* start the timeout daemon */
-	ret =3D afs_kafstimod_start();
+	/* initialise the VL update process */
+	ret =3D afs_vlocation_update_init();
 	if (ret < 0)
-		goto error_kafstimod;
+		goto error_vl_update_init;
=20
-	/* start the async operation daemon */
-	ret =3D afs_kafsasyncd_start();
-	if (ret < 0)
-		goto error_kafsasyncd;
+	/* initialise the callback update process */
+	ret =3D afs_callback_update_init();
=20
 	/* create the RxRPC transport */
-	ret =3D rxrpc_create_transport(7001, &afs_transport);
+	ret =3D afs_open_socket();
 	if (ret < 0)
-		goto error_transport;
-
-	afs_transport->peer_ops =3D &afs_peer_ops;
+		goto error_open_socket;
=20
 	/* register the filesystems */
 	ret =3D afs_fs_init();
@@ -119,17 +88,16 @@ static int __init afs_init(void)
 	return ret;
=20
 error_fs:
-	rxrpc_put_transport(afs_transport);
-error_transport:
-	afs_kafsasyncd_stop();
-error_kafsasyncd:
-	afs_kafstimod_stop();
-error_kafstimod:
+	afs_close_socket();
+error_open_socket:
+error_vl_update_init:
 error_cell_init:
 #ifdef AFS_CACHING_SUPPORT
 	cachefs_unregister_netfs(&afs_cache_netfs);
 error_cache:
 #endif
+	afs_callback_update_kill();
+	afs_vlocation_purge();
 	afs_cell_purge();
 	afs_proc_cleanup();
 	printk(KERN_ERR "kAFS: failed to register: %d\n", ret);
@@ -149,9 +117,11 @@ static void __exit afs_exit(void)
 	printk(KERN_INFO "kAFS: Red Hat AFS client v0.1 unregistering.\n");
=20
 	afs_fs_exit();
-	rxrpc_put_transport(afs_transport);
-	afs_kafstimod_stop();
-	afs_kafsasyncd_stop();
+	afs_close_socket();
+	afs_purge_servers();
+	afs_callback_update_kill();
+	afs_vlocation_purge();
+	flush_scheduled_work();
 	afs_cell_purge();
 #ifdef AFS_CACHING_SUPPORT
 	cachefs_unregister_netfs(&afs_cache_netfs);
@@ -160,64 +130,3 @@ static void __exit afs_exit(void)
 }
=20
 module_exit(afs_exit);
-
-/*
- * notification that new peer record is being added
- * - called from krxsecd
- * - return an error to induce an abort
- * - mustn't sleep (caller holds an rwlock)
- */
-static int afs_adding_peer(struct rxrpc_peer *peer)
-{
-	struct afs_server *server;
-	int ret;
-
-	_debug("kAFS: Adding new peer %08x\n", ntohl(peer->addr.s_addr));
-
-	/* determine which server the peer resides in (if any) */
-	ret =3D afs_server_find_by_peer(peer, &server);
-	if (ret < 0)
-		return ret; /* none that we recognise, so abort */
-
-	_debug("Server %p{u=3D%d}\n", server, atomic_read(&server->usage));
-
-	_debug("Cell %p{u=3D%d}\n",
-	       server->cell, atomic_read(&server->cell->usage));
-
-	/* cross-point the structs under a global lock */
-	spin_lock(&afs_server_peer_lock);
-	peer->user =3D server;
-	server->peer =3D peer;
-	spin_unlock(&afs_server_peer_lock);
-
-	afs_put_server(server);
-
-	return 0;
-}
-
-/*
- * notification that a peer record is being discarded
- * - called from krxiod or krxsecd
- */
-static void afs_discarding_peer(struct rxrpc_peer *peer)
-{
-	struct afs_server *server;
-
-	_enter("%p",peer);
-
-	_debug("Discarding peer %08x (rtt=3D%lu.%lumS)\n",
-	       ntohl(peer->addr.s_addr),
-	       (long) (peer->rtt / 1000),
-	       (long) (peer->rtt % 1000));
-
-	/* uncross-point the structs under a global lock */
-	spin_lock(&afs_server_peer_lock);
-	server =3D peer->user;
-	if (server) {
-		peer->user =3D NULL;
-		server->peer =3D NULL;
-	}
-	spin_unlock(&afs_server_peer_lock);
-
-	_leave("");
-}
diff --git a/fs/afs/misc.c b/fs/afs/misc.c
index 55bc677..98e9276 100644
--- a/fs/afs/misc.c
+++ b/fs/afs/misc.c
@@ -1,6 +1,6 @@
 /* miscellaneous bits
  *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2002, 2007 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -12,18 +12,19 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/errno.h>
-#include "errors.h"
 #include "internal.h"
+#include "afs_fs.h"
=20
 /*
  * convert an AFS abort code to a Linux error number
  */
-int afs_abort_to_error(int abortcode)
+int afs_abort_to_error(u32 abort_code)
 {
-	switch (abortcode) {
+	switch (abort_code) {
+	case 13:		return -EACCES;
 	case VSALVAGE:		return -EIO;
 	case VNOVNODE:		return -ENOENT;
-	case VNOVOL:		return -ENXIO;
+	case VNOVOL:		return -ENOMEDIUM;
 	case VVOLEXISTS:	return -EEXIST;
 	case VNOSERVICE:	return -EIO;
 	case VOFFLINE:		return -ENOENT;
diff --git a/fs/afs/mntpt.c b/fs/afs/mntpt.c
index ca3fa81..08c11a0 100644
--- a/fs/afs/mntpt.c
+++ b/fs/afs/mntpt.c
@@ -18,10 +18,6 @@
 #include <linux/mount.h>
 #include <linux/namei.h>
 #include <linux/mnt_namespace.h>
-#include "super.h"
-#include "cell.h"
-#include "volume.h"
-#include "vnode.h"
 #include "internal.h"
=20
=20
@@ -30,6 +26,7 @@ static struct dentry *afs_mntpt_lookup(struct inode *=
dir,
 				       struct nameidata *nd);
 static int afs_mntpt_open(struct inode *inode, struct file *file);
 static void *afs_mntpt_follow_link(struct dentry *dentry, struct namei=
data *nd);
+static void afs_mntpt_expiry_timed_out(struct work_struct *work);
=20
 const struct file_operations afs_mntpt_file_operations =3D {
 	.open		=3D afs_mntpt_open,
@@ -43,16 +40,9 @@ const struct inode_operations afs_mntpt_inode_operat=
ions =3D {
 };
=20
 static LIST_HEAD(afs_vfsmounts);
+static DECLARE_DELAYED_WORK(afs_mntpt_expiry_timer, afs_mntpt_expiry_t=
imed_out);
=20
-static void afs_mntpt_expiry_timed_out(struct afs_timer *timer);
-
-struct afs_timer_ops afs_mntpt_expiry_timer_ops =3D {
-	.timed_out	=3D afs_mntpt_expiry_timed_out,
-};
-
-struct afs_timer afs_mntpt_expiry_timer;
-
-unsigned long afs_mntpt_expiry_timeout =3D 20;
+unsigned long afs_mntpt_expiry_timeout =3D 10 * 60;
=20
 /*
  * check a symbolic link to see whether it actually encodes a mountpoi=
nt
@@ -84,7 +74,7 @@ int afs_mntpt_check_symlink(struct afs_vnode *vnode)
=20
 	/* examine the symlink's contents */
 	size =3D vnode->status.size;
-	_debug("symlink to %*.*s", size, (int) size, buf);
+	_debug("symlink to %*.*s", (int) size, (int) size, buf);
=20
 	if (size > 2 &&
 	    (buf[0] =3D=3D '%' || buf[0] =3D=3D '#') &&
@@ -92,7 +82,7 @@ int afs_mntpt_check_symlink(struct afs_vnode *vnode)
 	    ) {
 		_debug("symlink is a mountpoint");
 		spin_lock(&vnode->lock);
-		vnode->flags |=3D AFS_VNODE_MOUNTPOINT;
+		set_bit(AFS_VNODE_MOUNTPOINT, &vnode->flags);
 		spin_unlock(&vnode->lock);
 	}
=20
@@ -113,7 +103,7 @@ static struct dentry *afs_mntpt_lookup(struct inode=
 *dir,
 				       struct dentry *dentry,
 				       struct nameidata *nd)
 {
-	kenter("%p,%p{%p{%s},%s}",
+	_enter("%p,%p{%p{%s},%s}",
 	       dir,
 	       dentry,
 	       dentry->d_parent,
@@ -129,7 +119,7 @@ static struct dentry *afs_mntpt_lookup(struct inode=
 *dir,
  */
 static int afs_mntpt_open(struct inode *inode, struct file *file)
 {
-	kenter("%p,%p{%p{%s},%s}",
+	_enter("%p,%p{%p{%s},%s}",
 	       inode, file,
 	       file->f_path.dentry->d_parent,
 	       file->f_path.dentry->d_parent ?
@@ -152,7 +142,7 @@ static struct vfsmount *afs_mntpt_do_automount(stru=
ct dentry *mntpt)
 	char *buf, *devname =3D NULL, *options =3D NULL;
 	int ret;
=20
-	kenter("{%s}", mntpt->d_name.name);
+	_enter("{%s}", mntpt->d_name.name);
=20
 	BUG_ON(!mntpt->d_inode);
=20
@@ -196,13 +186,13 @@ static struct vfsmount *afs_mntpt_do_automount(st=
ruct dentry *mntpt)
 		strcat(options, ",rwpath");
=20
 	/* try and do the mount */
-	kdebug("--- attempting mount %s -o %s ---", devname, options);
+	_debug("--- attempting mount %s -o %s ---", devname, options);
 	mnt =3D vfs_kern_mount(&afs_fs_type, 0, devname, options);
-	kdebug("--- mount result %p ---", mnt);
+	_debug("--- mount result %p ---", mnt);
=20
 	free_page((unsigned long) devname);
 	free_page((unsigned long) options);
-	kleave(" =3D %p", mnt);
+	_leave(" =3D %p", mnt);
 	return mnt;
=20
 error:
@@ -212,7 +202,7 @@ error:
 		free_page((unsigned long) devname);
 	if (options)
 		free_page((unsigned long) options);
-	kleave(" =3D %d", ret);
+	_leave(" =3D %d", ret);
 	return ERR_PTR(ret);
 }
=20
@@ -222,51 +212,81 @@ error:
 static void *afs_mntpt_follow_link(struct dentry *dentry, struct namei=
data *nd)
 {
 	struct vfsmount *newmnt;
-	struct dentry *old_dentry;
 	int err;
=20
-	kenter("%p{%s},{%s:%p{%s}}",
+	_enter("%p{%s},{%s:%p{%s}}",
 	       dentry,
 	       dentry->d_name.name,
 	       nd->mnt->mnt_devname,
 	       dentry,
 	       nd->dentry->d_name.name);
=20
-	newmnt =3D afs_mntpt_do_automount(dentry);
+	dput(nd->dentry);
+	nd->dentry =3D dget(dentry);
+
+	newmnt =3D afs_mntpt_do_automount(nd->dentry);
 	if (IS_ERR(newmnt)) {
 		path_release(nd);
 		return (void *)newmnt;
 	}
=20
-	old_dentry =3D nd->dentry;
-	nd->dentry =3D dentry;
-	err =3D do_add_mount(newmnt, nd, 0, &afs_vfsmounts);
-	nd->dentry =3D old_dentry;
-
-	path_release(nd);
-
-	if (!err) {
-		mntget(newmnt);
+	mntget(newmnt);
+	err =3D do_add_mount(newmnt, nd, MNT_SHRINKABLE, &afs_vfsmounts);
+	switch (err) {
+	case 0:
+		path_release(nd);
 		nd->mnt =3D newmnt;
-		dget(newmnt->mnt_root);
-		nd->dentry =3D newmnt->mnt_root;
+		nd->dentry =3D dget(newmnt->mnt_root);
+		schedule_delayed_work(&afs_mntpt_expiry_timer,
+				      afs_mntpt_expiry_timeout * HZ);
+		break;
+	case -EBUSY:
+		/* someone else made a mount here whilst we were busy */
+		while (d_mountpoint(nd->dentry) &&
+		       follow_down(&nd->mnt, &nd->dentry))
+			;
+		err =3D 0;
+	default:
+		mntput(newmnt);
+		break;
 	}
=20
-	kleave(" =3D %d", err);
+	_leave(" =3D %d", err);
 	return ERR_PTR(err);
 }
=20
 /*
  * handle mountpoint expiry timer going off
  */
-static void afs_mntpt_expiry_timed_out(struct afs_timer *timer)
+static void afs_mntpt_expiry_timed_out(struct work_struct *work)
 {
-	kenter("");
+	_enter("");
+
+	if (!list_empty(&afs_vfsmounts)) {
+		mark_mounts_for_expiry(&afs_vfsmounts);
+		schedule_delayed_work(&afs_mntpt_expiry_timer,
+				      afs_mntpt_expiry_timeout * HZ);
+	}
+
+	_leave("");
+}
=20
-	mark_mounts_for_expiry(&afs_vfsmounts);
+/*
+ * kill the AFS mountpoint timer if it's still running
+ */
+void afs_mntpt_kill_timer(void)
+{
+	_enter("");
=20
-	afs_kafstimod_add_timer(&afs_mntpt_expiry_timer,
-				afs_mntpt_expiry_timeout * HZ);
+	ASSERT(list_empty(&afs_vfsmounts));
+	cancel_delayed_work(&afs_mntpt_expiry_timer);
+	flush_scheduled_work();
+}
=20
-	kleave("");
+/*
+ * begin unmount by attempting to remove all automounted mountpoints w=
e added
+ */
+void afs_umount_begin(struct vfsmount *vfsmnt, int flags)
+{
+	shrink_submounts(vfsmnt, &afs_vfsmounts);
 }
diff --git a/fs/afs/mount.h b/fs/afs/mount.h
deleted file mode 100644
index 41b8483..0000000
--- a/fs/afs/mount.h
+++ /dev/null
@@ -1,23 +0,0 @@
-/* mount parameters
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef AFS_MOUNT_H
-#define AFS_MOUNT_H
-
-struct afs_mountdata {
-	const char		*volume;	/* name of volume */
-	const char		*cell;		/* name of cell containing volume */
-	const char		*cache;		/* name of cache block device */
-	size_t			nservers;	/* number of server addresses listed */
-	uint32_t		servers[10];	/* IP addresses of servers in this cell */
-};
-
-#endif /* AFS_MOUNT_H */
diff --git a/fs/afs/proc.c b/fs/afs/proc.c
index 5ebcc0c..d5601f6 100644
--- a/fs/afs/proc.c
+++ b/fs/afs/proc.c
@@ -13,8 +13,6 @@
 #include <linux/module.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
-#include "cell.h"
-#include "volume.h"
 #include <asm/uaccess.h>
 #include "internal.h"
=20
@@ -315,10 +313,14 @@ static ssize_t afs_proc_cells_write(struct file *=
file, const char __user *buf,
=20
 	if (strcmp(kbuf, "add") =3D=3D 0) {
 		struct afs_cell *cell;
-		ret =3D afs_cell_create(name, args, &cell);
-		if (ret < 0)
+
+		cell =3D afs_cell_create(name, args);
+		if (IS_ERR(cell)) {
+			ret =3D PTR_ERR(cell);
 			goto done;
+		}
=20
+		afs_put_cell(cell);
 		printk("kAFS: Added new cell '%s'\n", name);
 	} else {
 		goto inval;
@@ -472,7 +474,7 @@ static int afs_proc_cell_volumes_open(struct inode =
*inode, struct file *file)
 	struct seq_file *m;
 	int ret;
=20
-	cell =3D afs_get_cell_maybe((struct afs_cell **) &PDE(inode)->data);
+	cell =3D PDE(inode)->data;
 	if (!cell)
 		return -ENOENT;
=20
@@ -491,13 +493,7 @@ static int afs_proc_cell_volumes_open(struct inode=
 *inode, struct file *file)
  */
 static int afs_proc_cell_volumes_release(struct inode *inode, struct f=
ile *file)
 {
-	struct afs_cell *cell =3D PDE(inode)->data;
-	int ret;
-
-	ret =3D seq_release(inode, file);
-
-	afs_put_cell(cell);
-	return ret;
+	return seq_release(inode, file);
 }
=20
 /*
@@ -557,6 +553,16 @@ static void afs_proc_cell_volumes_stop(struct seq_=
file *p, void *v)
 	up_read(&cell->vl_sem);
 }
=20
+const char afs_vlocation_states[][4] =3D {
+	[AFS_VL_NEW]			=3D "New",
+	[AFS_VL_CREATING]		=3D "Crt",
+	[AFS_VL_VALID]			=3D "Val",
+	[AFS_VL_NO_VOLUME]		=3D "NoV",
+	[AFS_VL_UPDATING]		=3D "Upd",
+	[AFS_VL_VOLUME_DELETED]		=3D "Del",
+	[AFS_VL_UNCERTAIN]		=3D "Unc",
+};
+
 /*
  * display a header line followed by a load of volume lines
  */
@@ -567,13 +573,14 @@ static int afs_proc_cell_volumes_show(struct seq_=
file *m, void *v)
=20
 	/* display header on line 1 */
 	if (v =3D=3D (void *) 1) {
-		seq_puts(m, "USE VLID[0]  VLID[1]  VLID[2]  NAME\n");
+		seq_puts(m, "USE STT VLID[0]  VLID[1]  VLID[2]  NAME\n");
 		return 0;
 	}
=20
 	/* display one cell per line on subsequent lines */
-	seq_printf(m, "%3d %08x %08x %08x %s\n",
+	seq_printf(m, "%3d %s %08x %08x %08x %s\n",
 		   atomic_read(&vlocation->usage),
+		   afs_vlocation_states[vlocation->state],
 		   vlocation->vldb.vid[0],
 		   vlocation->vldb.vid[1],
 		   vlocation->vldb.vid[2],
@@ -592,11 +599,11 @@ static int afs_proc_cell_vlservers_open(struct in=
ode *inode, struct file *file)
 	struct seq_file *m;
 	int ret;
=20
-	cell =3D afs_get_cell_maybe((struct afs_cell**)&PDE(inode)->data);
+	cell =3D PDE(inode)->data;
 	if (!cell)
 		return -ENOENT;
=20
-	ret =3D seq_open(file,&afs_proc_cell_vlservers_ops);
+	ret =3D seq_open(file, &afs_proc_cell_vlservers_ops);
 	if (ret<0)
 		return ret;
=20
@@ -612,13 +619,7 @@ static int afs_proc_cell_vlservers_open(struct ino=
de *inode, struct file *file)
 static int afs_proc_cell_vlservers_release(struct inode *inode,
 					   struct file *file)
 {
-	struct afs_cell *cell =3D PDE(inode)->data;
-	int ret;
-
-	ret =3D seq_release(inode,file);
-
-	afs_put_cell(cell);
-	return ret;
+	return seq_release(inode, file);
 }
=20
 /*
@@ -703,7 +704,7 @@ static int afs_proc_cell_servers_open(struct inode =
*inode, struct file *file)
 	struct seq_file *m;
 	int ret;
=20
-	cell =3D afs_get_cell_maybe((struct afs_cell **) &PDE(inode)->data);
+	cell =3D PDE(inode)->data;
 	if (!cell)
 		return -ENOENT;
=20
@@ -722,13 +723,7 @@ static int afs_proc_cell_servers_open(struct inode=
 *inode, struct file *file)
 static int afs_proc_cell_servers_release(struct inode *inode,
 					 struct file *file)
 {
-	struct afs_cell *cell =3D PDE(inode)->data;
-	int ret;
-
-	ret =3D seq_release(inode, file);
-
-	afs_put_cell(cell);
-	return ret;
+	return seq_release(inode, file);
 }
=20
 /*
@@ -736,7 +731,7 @@ static int afs_proc_cell_servers_release(struct ino=
de *inode,
  * first item
  */
 static void *afs_proc_cell_servers_start(struct seq_file *m, loff_t *_=
pos)
-	__acquires(m->private->sv_lock)
+	__acquires(m->private->servers_lock)
 {
 	struct list_head *_p;
 	struct afs_cell *cell =3D m->private;
@@ -745,7 +740,7 @@ static void *afs_proc_cell_servers_start(struct seq=
_file *m, loff_t *_pos)
 	_enter("cell=3D%p pos=3D%Ld", cell, *_pos);
=20
 	/* lock the list against modification */
-	read_lock(&cell->sv_lock);
+	read_lock(&cell->servers_lock);
=20
 	/* allow for the header line */
 	if (!pos)
@@ -753,11 +748,11 @@ static void *afs_proc_cell_servers_start(struct s=
eq_file *m, loff_t *_pos)
 	pos--;
=20
 	/* find the n'th element in the list */
-	list_for_each(_p, &cell->sv_list)
+	list_for_each(_p, &cell->servers)
 		if (!pos--)
 			break;
=20
-	return _p !=3D &cell->sv_list ? _p : NULL;
+	return _p !=3D &cell->servers ? _p : NULL;
 }
=20
 /*
@@ -774,20 +769,20 @@ static void *afs_proc_cell_servers_next(struct se=
q_file *p, void *v,
 	(*_pos)++;
=20
 	_p =3D v;
-	_p =3D v =3D=3D (void *) 1 ? cell->sv_list.next : _p->next;
+	_p =3D v =3D=3D (void *) 1 ? cell->servers.next : _p->next;
=20
-	return _p !=3D &cell->sv_list ? _p : NULL;
+	return _p !=3D &cell->servers ? _p : NULL;
 }
=20
 /*
  * clean up after reading from the cells list
  */
 static void afs_proc_cell_servers_stop(struct seq_file *p, void *v)
-	__releases(p->private->sv_lock)
+	__releases(p->private->servers_lock)
 {
 	struct afs_cell *cell =3D p->private;
=20
-	read_unlock(&cell->sv_lock);
+	read_unlock(&cell->servers_lock);
 }
=20
 /*
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
new file mode 100644
index 0000000..b927742
--- /dev/null
+++ b/fs/afs/rxrpc.c
@@ -0,0 +1,666 @@
+/* Maintain an RxRPC server socket to do AFS communications through
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include <rxrpc/packet.h>
+#include "internal.h"
+#include "afs_cm.h"
+
+static struct socket *afs_socket; /* my RxRPC socket */
+static struct workqueue_struct *afs_async_calls;
+
+static void afs_wake_up_call_waiter(struct afs_call *);
+static int afs_wait_for_call_to_complete(struct afs_call *);
+static void afs_wake_up_async_call(struct afs_call *);
+static int afs_dont_wait_for_call_to_complete(struct afs_call *);
+static void afs_process_async_call(struct work_struct *);
+static void afs_rx_interceptor(struct sock *, unsigned long, struct sk=
_buff *);
+static int afs_deliver_cm_op_id(struct afs_call *, struct sk_buff *, b=
ool);
+
+/* synchronous call management */
+const struct afs_wait_mode afs_sync_call =3D {
+	.rx_wakeup	=3D afs_wake_up_call_waiter,
+	.wait		=3D afs_wait_for_call_to_complete,
+};
+
+/* asynchronous call management */
+const struct afs_wait_mode afs_async_call =3D {
+	.rx_wakeup	=3D afs_wake_up_async_call,
+	.wait		=3D afs_dont_wait_for_call_to_complete,
+};
+
+/* asynchronous incoming call management */
+static const struct afs_wait_mode afs_async_incoming_call =3D {
+	.rx_wakeup	=3D afs_wake_up_async_call,
+};
+
+/* asynchronous incoming call initial processing */
+static const struct afs_call_type afs_RXCMxxxx =3D {
+	.deliver	=3D afs_deliver_cm_op_id,
+	.abort_to_error	=3D afs_abort_to_error,
+};
+
+static void afs_collect_incoming_call(struct work_struct *);
+
+static struct sk_buff_head afs_incoming_calls;
+static DECLARE_WORK(afs_collect_incoming_call_work, afs_collect_incomi=
ng_call);
+
+/*
+ * open an RxRPC socket and bind it to be a server for callback notifi=
cations
+ * - the socket is left in blocking mode and non-blocking ops use MSG_=
DONTWAIT
+ */
+int afs_open_socket(void)
+{
+	struct sockaddr_rxrpc srx;
+	struct socket *socket;
+	int ret;
+
+	_enter("");
+
+	skb_queue_head_init(&afs_incoming_calls);
+
+	afs_async_calls =3D create_singlethread_workqueue("kafsd");
+	if (!afs_async_calls) {
+		_leave(" =3D -ENOMEM [wq]");
+		return -ENOMEM;
+	}
+
+	ret =3D sock_create_kern(AF_RXRPC, SOCK_DGRAM, PF_INET, &socket);
+	if (ret < 0) {
+		destroy_workqueue(afs_async_calls);
+		_leave(" =3D %d [socket]", ret);
+		return ret;
+	}
+
+	socket->sk->sk_allocation =3D GFP_NOFS;
+
+	/* bind the callback manager's address to make this a server socket *=
/
+	srx.srx_family			=3D AF_RXRPC;
+	srx.srx_service			=3D CM_SERVICE;
+	srx.transport_type		=3D SOCK_DGRAM;
+	srx.transport_len		=3D sizeof(srx.transport.sin);
+	srx.transport.sin.sin_family	=3D AF_INET;
+	srx.transport.sin.sin_port	=3D htons(AFS_CM_PORT);
+	memset(&srx.transport.sin.sin_addr, 0,
+	       sizeof(srx.transport.sin.sin_addr));
+
+	ret =3D kernel_bind(socket, (struct sockaddr *) &srx, sizeof(srx));
+	if (ret < 0) {
+		sock_release(socket);
+		_leave(" =3D %d [bind]", ret);
+		return ret;
+	}
+
+	rxrpc_kernel_intercept_rx_messages(socket, afs_rx_interceptor);
+
+	afs_socket =3D socket;
+	_leave(" =3D 0");
+	return 0;
+}
+
+/*
+ * close the RxRPC socket AFS was using
+ */
+void afs_close_socket(void)
+{
+	_enter("");
+
+	sock_release(afs_socket);
+
+	_debug("dework");
+	destroy_workqueue(afs_async_calls);
+	_leave("");
+}
+
+/*
+ * allocate a call with flat request and reply buffers
+ */
+struct afs_call *afs_alloc_flat_call(const struct afs_call_type *type,
+				     size_t request_size, size_t reply_size)
+{
+	struct afs_call *call;
+
+	call =3D kzalloc(sizeof(*call), GFP_NOFS);
+	if (!call)
+		goto nomem_call;
+
+	if (request_size) {
+		call->request =3D kmalloc(request_size, GFP_NOFS);
+		if (!call->request)
+			goto nomem_request;
+	}
+
+	if (reply_size) {
+		call->buffer =3D kmalloc(reply_size, GFP_NOFS);
+		if (!call->buffer)
+			goto nomem_buffer;
+	}
+
+	call->type =3D type;
+	call->request_size =3D request_size;
+	call->reply_max =3D reply_size;
+
+	init_waitqueue_head(&call->waitq);
+	skb_queue_head_init(&call->rx_queue);
+	return call;
+
+nomem_buffer:
+	kfree(call->request);
+nomem_request:
+	kfree(call);
+nomem_call:
+	return NULL;
+}
+
+/*
+ * clean up a call with flat buffer
+ */
+void afs_flat_call_destructor(struct afs_call *call)
+{
+	_enter("");
+
+	kfree(call->request);
+	call->request =3D NULL;
+	kfree(call->buffer);
+	call->buffer =3D NULL;
+}
+
+/*
+ * initiate a call
+ */
+int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t g=
fp,
+		  const struct afs_wait_mode *wait_mode)
+{
+	struct sockaddr_rxrpc srx;
+	struct rxrpc_call *rxcall;
+	struct msghdr msg;
+	struct kvec iov[1];
+	int ret;
+
+	_enter("%x,{%d},", addr->s_addr, ntohs(call->port));
+
+	call->wait_mode =3D wait_mode;
+	INIT_WORK(&call->async_work, afs_process_async_call);
+
+	memset(&srx, 0, sizeof(srx));
+	srx.srx_family =3D AF_RXRPC;
+	srx.srx_service =3D call->service_id;
+	srx.transport_type =3D SOCK_DGRAM;
+	srx.transport_len =3D sizeof(srx.transport.sin);
+	srx.transport.sin.sin_family =3D AF_INET;
+	srx.transport.sin.sin_port =3D call->port;
+	memcpy(&srx.transport.sin.sin_addr, addr, 4);
+
+	/* create a call */
+	rxcall =3D rxrpc_kernel_begin_call(afs_socket, &srx, call->key,
+					 (unsigned long) call, gfp);
+	if (IS_ERR(rxcall)) {
+		ret =3D PTR_ERR(rxcall);
+		goto error_kill_call;
+	}
+
+	call->rxcall =3D rxcall;
+
+	/* send the request */
+	iov[0].iov_base	=3D call->request;
+	iov[0].iov_len	=3D call->request_size;
+
+	msg.msg_name		=3D NULL;
+	msg.msg_namelen		=3D 0;
+	msg.msg_iov		=3D (struct iovec *) iov;
+	msg.msg_iovlen		=3D 1;
+	msg.msg_control		=3D NULL;
+	msg.msg_controllen	=3D 0;
+	msg.msg_flags		=3D 0;
+
+	/* have to change the state *before* sending the last packet as RxRPC
+	 * might give us the reply before it returns from sending the
+	 * request */
+	call->state =3D AFS_CALL_AWAIT_REPLY;
+	ret =3D rxrpc_kernel_send_data(rxcall, &msg, call->request_size);
+	if (ret < 0)
+		goto error_do_abort;
+
+	/* at this point, an async call may no longer exist as it may have
+	 * already completed */
+	return wait_mode->wait(call);
+
+error_do_abort:
+	rxrpc_kernel_abort_call(rxcall, RX_USER_ABORT);
+	rxrpc_kernel_end_call(rxcall);
+error_kill_call:
+	call->type->destructor(call);
+	ASSERT(skb_queue_empty(&call->rx_queue));
+	kfree(call);
+	_leave(" =3D %d", ret);
+	return ret;
+}
+
+/*
+ * handles intercepted messages that were arriving in the socket's Rx =
queue
+ * - called with the socket receive queue lock held to ensure message =
ordering
+ * - called with softirqs disabled
+ */
+static void afs_rx_interceptor(struct sock *sk, unsigned long user_cal=
l_ID,
+			       struct sk_buff *skb)
+{
+	struct afs_call *call =3D (struct afs_call *) user_call_ID;
+
+	_enter("%p,,%u", call, skb->mark);
+
+	ASSERTCMP(sk, =3D=3D, afs_socket->sk);
+
+	if (!call) {
+		/* its an incoming call for our callback service */
+		__skb_queue_tail(&afs_incoming_calls, skb);
+		schedule_work(&afs_collect_incoming_call_work);
+	} else {
+		/* route the messages directly to the appropriate call */
+		__skb_queue_tail(&call->rx_queue, skb);
+		call->wait_mode->rx_wakeup(call);
+	}
+
+	_leave("");
+}
+
+/*
+ * deliver messages to a call
+ */
+static void afs_deliver_to_call(struct afs_call *call)
+{
+	struct sk_buff *skb;
+	bool last;
+	u32 abort_code;
+	int ret;
+
+	_enter("");
+
+	while ((call->state =3D=3D AFS_CALL_AWAIT_REPLY ||
+		call->state =3D=3D AFS_CALL_AWAIT_OP_ID ||
+		call->state =3D=3D AFS_CALL_AWAIT_REQUEST ||
+		call->state =3D=3D AFS_CALL_AWAIT_ACK) &&
+	       (skb =3D skb_dequeue(&call->rx_queue))) {
+		switch (skb->mark) {
+		case RXRPC_SKB_MARK_DATA:
+			_debug("Rcv DATA");
+			last =3D rxrpc_kernel_is_data_last(skb);
+			ret =3D call->type->deliver(call, skb, last);
+			switch (ret) {
+			case 0:
+				if (last &&
+				    call->state =3D=3D AFS_CALL_AWAIT_REPLY)
+					call->state =3D AFS_CALL_COMPLETE;
+				break;
+			case -ENOTCONN:
+				abort_code =3D RX_CALL_DEAD;
+				goto do_abort;
+			case -ENOTSUPP:
+				abort_code =3D RX_INVALID_OPERATION;
+				goto do_abort;
+			default:
+				abort_code =3D RXGEN_CC_UNMARSHAL;
+				if (call->state !=3D AFS_CALL_AWAIT_REPLY)
+					abort_code =3D RXGEN_SS_UNMARSHAL;
+			do_abort:
+				rxrpc_kernel_abort_call(call->rxcall,
+							abort_code);
+				call->error =3D ret;
+				call->state =3D AFS_CALL_ERROR;
+				break;
+			}
+			rxrpc_kernel_data_delivered(skb);
+			skb =3D NULL;
+			break;
+		case RXRPC_SKB_MARK_FINAL_ACK:
+			_debug("Rcv ACK");
+			call->state =3D AFS_CALL_COMPLETE;
+			break;
+		case RXRPC_SKB_MARK_BUSY:
+			_debug("Rcv BUSY");
+			call->error =3D -EBUSY;
+			call->state =3D AFS_CALL_BUSY;
+			break;
+		case RXRPC_SKB_MARK_REMOTE_ABORT:
+			abort_code =3D rxrpc_kernel_get_abort_code(skb);
+			call->error =3D call->type->abort_to_error(abort_code);
+			call->state =3D AFS_CALL_ABORTED;
+			_debug("Rcv ABORT %u -> %d", abort_code, call->error);
+			break;
+		case RXRPC_SKB_MARK_NET_ERROR:
+			call->error =3D -rxrpc_kernel_get_error_number(skb);
+			call->state =3D AFS_CALL_ERROR;
+			_debug("Rcv NET ERROR %d", call->error);
+			break;
+		case RXRPC_SKB_MARK_LOCAL_ERROR:
+			call->error =3D -rxrpc_kernel_get_error_number(skb);
+			call->state =3D AFS_CALL_ERROR;
+			_debug("Rcv LOCAL ERROR %d", call->error);
+			break;
+		default:
+			BUG();
+			break;
+		}
+
+		rxrpc_kernel_free_skb(skb);
+	}
+
+	/* make sure the queue is empty if the call is done with (we might ha=
ve
+	 * aborted the call early because of an unmarshalling error) */
+	if (call->state >=3D AFS_CALL_COMPLETE) {
+		while ((skb =3D skb_dequeue(&call->rx_queue)))
+			rxrpc_kernel_free_skb(skb);
+		if (call->incoming) {
+			rxrpc_kernel_end_call(call->rxcall);
+			call->type->destructor(call);
+			ASSERT(skb_queue_empty(&call->rx_queue));
+			kfree(call);
+		}
+	}
+
+	_leave("");
+}
+
+/*
+ * wait synchronously for a call to complete
+ */
+static int afs_wait_for_call_to_complete(struct afs_call *call)
+{
+	struct sk_buff *skb;
+	int ret;
+
+	DECLARE_WAITQUEUE(myself, current);
+
+	_enter("");
+
+	add_wait_queue(&call->waitq, &myself);
+	for (;;) {
+		set_current_state(TASK_INTERRUPTIBLE);
+
+		/* deliver any messages that are in the queue */
+		if (!skb_queue_empty(&call->rx_queue)) {
+			__set_current_state(TASK_RUNNING);
+			afs_deliver_to_call(call);
+			continue;
+		}
+
+		ret =3D call->error;
+		if (call->state >=3D AFS_CALL_COMPLETE)
+			break;
+		ret =3D -EINTR;
+		if (signal_pending(current))
+			break;
+		schedule();
+	}
+
+	remove_wait_queue(&call->waitq, &myself);
+	__set_current_state(TASK_RUNNING);
+
+	/* kill the call */
+	if (call->state < AFS_CALL_COMPLETE) {
+		_debug("call incomplete");
+		rxrpc_kernel_abort_call(call->rxcall, RX_CALL_DEAD);
+		while ((skb =3D skb_dequeue(&call->rx_queue)))
+			rxrpc_kernel_free_skb(skb);
+	}
+
+	_debug("call complete");
+	rxrpc_kernel_end_call(call->rxcall);
+	call->type->destructor(call);
+	ASSERT(skb_queue_empty(&call->rx_queue));
+	kfree(call);
+	_leave(" =3D %d", ret);
+	return ret;
+}
+
+/*
+ * wake up a waiting call
+ */
+static void afs_wake_up_call_waiter(struct afs_call *call)
+{
+	wake_up(&call->waitq);
+}
+
+/*
+ * wake up an asynchronous call
+ */
+static void afs_wake_up_async_call(struct afs_call *call)
+{
+	_enter("");
+	queue_work(afs_async_calls, &call->async_work);
+}
+
+/*
+ * put a call into asynchronous mode
+ * - mustn't touch the call descriptor as the call my have completed b=
y the
+ *   time we get here
+ */
+static int afs_dont_wait_for_call_to_complete(struct afs_call *call)
+{
+	_enter("");
+	return -EINPROGRESS;
+}
+
+/*
+ * delete an asynchronous call
+ */
+static void afs_delete_async_call(struct work_struct *work)
+{
+	struct afs_call *call =3D
+		container_of(work, struct afs_call, async_work);
+
+	_enter("");
+
+	ASSERT(skb_queue_empty(&call->rx_queue));
+	ASSERT(!work_pending(&call->async_work));
+	kfree(call);
+
+	_leave("");
+}
+
+/*
+ * perform processing on an asynchronous call
+ * - on a multiple-thread workqueue this work item may try to run on s=
everal
+ *   CPUs at the same time
+ */
+static void afs_process_async_call(struct work_struct *work)
+{
+	struct afs_call *call =3D
+		container_of(work, struct afs_call, async_work);
+
+	_enter("");
+
+	if (!skb_queue_empty(&call->rx_queue))
+		afs_deliver_to_call(call);
+
+	if (call->state >=3D AFS_CALL_COMPLETE && call->wait_mode) {
+		if (call->wait_mode->async_complete)
+			call->wait_mode->async_complete(call->reply,
+							call->error);
+		call->reply =3D NULL;
+
+		/* kill the call */
+		rxrpc_kernel_end_call(call->rxcall);
+		if (call->type->destructor)
+			call->type->destructor(call);
+
+		/* we can't just delete the call because the work item may be
+		 * queued */
+		PREPARE_WORK(&call->async_work, afs_delete_async_call);
+		queue_work(afs_async_calls, &call->async_work);
+	}
+
+	_leave("");
+}
+
+/*
+ * empty a socket buffer into a flat reply buffer
+ */
+void afs_transfer_reply(struct afs_call *call, struct sk_buff *skb)
+{
+	size_t len =3D skb->len;
+
+	if (skb_copy_bits(skb, 0, call->buffer + call->reply_size, len) < 0)
+		BUG();
+	call->reply_size +=3D len;
+}
+
+/*
+ * accept the backlog of incoming calls
+ */
+static void afs_collect_incoming_call(struct work_struct *work)
+{
+	struct rxrpc_call *rxcall;
+	struct afs_call *call =3D NULL;
+	struct sk_buff *skb;
+
+	while ((skb =3D skb_dequeue(&afs_incoming_calls))) {
+		_debug("new call");
+
+		/* don't need the notification */
+		rxrpc_kernel_free_skb(skb);
+
+		if (!call) {
+			call =3D kzalloc(sizeof(struct afs_call), GFP_KERNEL);
+			if (!call) {
+				rxrpc_kernel_reject_call(afs_socket);
+				return;
+			}
+
+			INIT_WORK(&call->async_work, afs_process_async_call);
+			call->wait_mode =3D &afs_async_incoming_call;
+			call->type =3D &afs_RXCMxxxx;
+			init_waitqueue_head(&call->waitq);
+			skb_queue_head_init(&call->rx_queue);
+			call->state =3D AFS_CALL_AWAIT_OP_ID;
+		}
+
+		rxcall =3D rxrpc_kernel_accept_call(afs_socket,
+						  (unsigned long) call);
+		if (!IS_ERR(rxcall)) {
+			call->rxcall =3D rxcall;
+			call =3D NULL;
+		}
+	}
+
+	kfree(call);
+}
+
+/*
+ * grab the operation ID from an incoming cache manager call
+ */
+static int afs_deliver_cm_op_id(struct afs_call *call, struct sk_buff =
*skb,
+				bool last)
+{
+	size_t len =3D skb->len;
+	void *oibuf =3D (void *) &call->operation_ID;
+
+	_enter("{%u},{%zu},%d", call->offset, len, last);
+
+	ASSERTCMP(call->offset, <, 4);
+
+	/* the operation ID forms the first four bytes of the request data */
+	len =3D min_t(size_t, len, 4 - call->offset);
+	if (skb_copy_bits(skb, 0, oibuf + call->offset, len) < 0)
+		BUG();
+	if (!pskb_pull(skb, len))
+		BUG();
+	call->offset +=3D len;
+
+	if (call->offset < 4) {
+		if (last) {
+			_leave(" =3D -EBADMSG [op ID short]");
+			return -EBADMSG;
+		}
+		_leave(" =3D 0 [incomplete]");
+		return 0;
+	}
+
+	call->state =3D AFS_CALL_AWAIT_REQUEST;
+
+	/* ask the cache manager to route the call (it'll change the call typ=
e
+	 * if successful) */
+	if (!afs_cm_incoming_call(call))
+		return -ENOTSUPP;
+
+	/* pass responsibility for the remainer of this message off to the
+	 * cache manager op */
+	return call->type->deliver(call, skb, last);
+}
+
+/*
+ * send an empty reply
+ */
+void afs_send_empty_reply(struct afs_call *call)
+{
+	struct msghdr msg;
+	struct iovec iov[1];
+
+	_enter("");
+
+	iov[0].iov_base		=3D NULL;
+	iov[0].iov_len		=3D 0;
+	msg.msg_name		=3D NULL;
+	msg.msg_namelen		=3D 0;
+	msg.msg_iov		=3D iov;
+	msg.msg_iovlen		=3D 0;
+	msg.msg_control		=3D NULL;
+	msg.msg_controllen	=3D 0;
+	msg.msg_flags		=3D 0;
+
+	call->state =3D AFS_CALL_AWAIT_ACK;
+	switch (rxrpc_kernel_send_data(call->rxcall, &msg, 0)) {
+	case 0:
+		_leave(" [replied]");
+		return;
+
+	case -ENOMEM:
+		_debug("oom");
+		rxrpc_kernel_abort_call(call->rxcall, RX_USER_ABORT);
+	default:
+		rxrpc_kernel_end_call(call->rxcall);
+		call->rxcall =3D NULL;
+		call->type->destructor(call);
+		ASSERT(skb_queue_empty(&call->rx_queue));
+		kfree(call);
+		_leave(" [error]");
+		return;
+	}
+}
+
+/*
+ * extract a piece of data from the received data socket buffers
+ */
+int afs_extract_data(struct afs_call *call, struct sk_buff *skb,
+		     bool last, void *buf, size_t count)
+{
+	size_t len =3D skb->len;
+
+	_enter("{%u},{%zu},%d,,%zu", call->offset, len, last, count);
+
+	ASSERTCMP(call->offset, <, count);
+
+	len =3D min_t(size_t, len, count - call->offset);
+	if (skb_copy_bits(skb, 0, buf + call->offset, len) < 0 ||
+	    !pskb_pull(skb, len))
+		BUG();
+	call->offset +=3D len;
+
+	if (call->offset < count) {
+		if (last) {
+			_leave(" =3D -EBADMSG [%d < %lu]", call->offset, count);
+			return -EBADMSG;
+		}
+		_leave(" =3D -EAGAIN");
+		return -EAGAIN;
+	}
+	return 0;
+}
diff --git a/fs/afs/server.c b/fs/afs/server.c
index 44b0ce5..d44bba3 100644
--- a/fs/afs/server.c
+++ b/fs/afs/server.c
@@ -1,6 +1,6 @@
 /* AFS server record management
  *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2002, 2007 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -11,127 +11,205 @@
=20
 #include <linux/sched.h>
 #include <linux/slab.h>
-#include <rxrpc/peer.h>
-#include <rxrpc/connection.h>
-#include "volume.h"
-#include "cell.h"
-#include "server.h"
-#include "transport.h"
-#include "vlclient.h"
-#include "kafstimod.h"
 #include "internal.h"
=20
-DEFINE_SPINLOCK(afs_server_peer_lock);
+unsigned afs_server_timeout =3D 10;	/* server timeout in seconds */
=20
-#define FS_SERVICE_ID		1	/* AFS Volume Location Service ID */
-#define VL_SERVICE_ID		52	/* AFS Volume Location Service ID */
+static void afs_reap_server(struct work_struct *);
=20
-static void __afs_server_timeout(struct afs_timer *timer)
+/* tree of all the servers, indexed by IP address */
+static struct rb_root afs_servers =3D RB_ROOT;
+static DEFINE_RWLOCK(afs_servers_lock);
+
+/* LRU list of all the servers not currently in use */
+static LIST_HEAD(afs_server_graveyard);
+static DEFINE_SPINLOCK(afs_server_graveyard_lock);
+static DECLARE_DELAYED_WORK(afs_server_reaper, afs_reap_server);
+
+/*
+ * install a server record in the master tree
+ */
+static int afs_install_server(struct afs_server *server)
 {
-	struct afs_server *server =3D
-		list_entry(timer, struct afs_server, timeout);
+	struct afs_server *xserver;
+	struct rb_node **pp, *p;
+	int ret;
+
+	_enter("%p", server);
=20
-	_debug("SERVER TIMEOUT [%p{u=3D%d}]",
-	       server, atomic_read(&server->usage));
+	write_lock(&afs_servers_lock);
+
+	ret =3D -EEXIST;
+	pp =3D &afs_servers.rb_node;
+	p =3D NULL;
+	while (*pp) {
+		p =3D *pp;
+		_debug("- consider %p", p);
+		xserver =3D rb_entry(p, struct afs_server, master_rb);
+		if (server->addr.s_addr < xserver->addr.s_addr)
+			pp =3D &(*pp)->rb_left;
+		else if (server->addr.s_addr > xserver->addr.s_addr)
+			pp =3D &(*pp)->rb_right;
+		else
+			goto error;
+	}
=20
-	afs_server_do_timeout(server);
-}
+	rb_link_node(&server->master_rb, p, pp);
+	rb_insert_color(&server->master_rb, &afs_servers);
+	ret =3D 0;
=20
-static const struct afs_timer_ops afs_server_timer_ops =3D {
-	.timed_out	=3D __afs_server_timeout,
-};
+error:
+	write_unlock(&afs_servers_lock);
+	return ret;
+}
=20
 /*
- * lookup a server record in a cell
- * - TODO: search the cell's server list
+ * allocate a new server record
  */
-int afs_server_lookup(struct afs_cell *cell, const struct in_addr *add=
r,
-		      struct afs_server **_server)
+static struct afs_server *afs_alloc_server(struct afs_cell *cell,
+					   const struct in_addr *addr)
 {
-	struct afs_server *server, *active, *zombie;
-	int loop;
+	struct afs_server *server;
=20
-	_enter("%p,%08x,", cell, ntohl(addr->s_addr));
+	_enter("");
=20
-	/* allocate and initialise a server record */
 	server =3D kzalloc(sizeof(struct afs_server), GFP_KERNEL);
-	if (!server) {
-		_leave(" =3D -ENOMEM");
-		return -ENOMEM;
+	if (server) {
+		atomic_set(&server->usage, 1);
+		server->cell =3D cell;
+
+		INIT_LIST_HEAD(&server->link);
+		INIT_LIST_HEAD(&server->grave);
+		init_rwsem(&server->sem);
+		spin_lock_init(&server->fs_lock);
+		server->fs_vnodes =3D RB_ROOT;
+		server->cb_promises =3D RB_ROOT;
+		spin_lock_init(&server->cb_lock);
+		init_waitqueue_head(&server->cb_break_waitq);
+		INIT_DELAYED_WORK(&server->cb_break_work,
+				  afs_dispatch_give_up_callbacks);
+
+		memcpy(&server->addr, addr, sizeof(struct in_addr));
+		server->addr.s_addr =3D addr->s_addr;
 	}
=20
-	atomic_set(&server->usage, 1);
+	_leave(" =3D %p{%d}", server, atomic_read(&server->usage));
+	return server;
+}
=20
-	INIT_LIST_HEAD(&server->link);
-	init_rwsem(&server->sem);
-	INIT_LIST_HEAD(&server->fs_callq);
-	spin_lock_init(&server->fs_lock);
-	INIT_LIST_HEAD(&server->cb_promises);
-	spin_lock_init(&server->cb_lock);
+/*
+ * get an FS-server record for a cell
+ */
+struct afs_server *afs_lookup_server(struct afs_cell *cell,
+				     const struct in_addr *addr)
+{
+	struct afs_server *server, *candidate;
=20
-	for (loop =3D 0; loop < AFS_SERVER_CONN_LIST_SIZE; loop++)
-		server->fs_conn_cnt[loop] =3D 4;
+	_enter("%p,"NIPQUAD_FMT, cell, NIPQUAD(addr->s_addr));
=20
-	memcpy(&server->addr, addr, sizeof(struct in_addr));
-	server->addr.s_addr =3D addr->s_addr;
+	/* quick scan of the list to see if we already have the server */
+	read_lock(&cell->servers_lock);
+=09
+	list_for_each_entry(server, &cell->servers, link) {
+		if (server->addr.s_addr =3D=3D addr->s_addr)
+			goto found_server_quickly;
+	}
+	read_unlock(&cell->servers_lock);
=20
-	afs_timer_init(&server->timeout, &afs_server_timer_ops);
+	candidate =3D afs_alloc_server(cell, addr);
+	if (!candidate) {
+		_leave(" =3D -ENOMEM");
+		return ERR_PTR(-ENOMEM);
+	}
=20
-	/* add to the cell */
-	write_lock(&cell->sv_lock);
+	write_lock(&cell->servers_lock);
=20
-	/* check the active list */
-	list_for_each_entry(active, &cell->sv_list, link) {
-		if (active->addr.s_addr =3D=3D addr->s_addr)
-			goto use_active_server;
+	/* check the cell's server list again */
+	list_for_each_entry(server, &cell->servers, link) {
+		if (server->addr.s_addr =3D=3D addr->s_addr)
+			goto found_server;
 	}
=20
-	/* check the inactive list */
-	spin_lock(&cell->sv_gylock);
-	list_for_each_entry(zombie, &cell->sv_graveyard, link) {
-		if (zombie->addr.s_addr =3D=3D addr->s_addr)
-			goto resurrect_server;
-	}
-	spin_unlock(&cell->sv_gylock);
+	_debug("new");
+	server =3D candidate;
+	if (afs_install_server(server) < 0)
+		goto server_in_two_cells;
=20
 	afs_get_cell(cell);
-	server->cell =3D cell;
-	list_add_tail(&server->link, &cell->sv_list);
-
-	write_unlock(&cell->sv_lock);
-
-	*_server =3D server;
-	_leave(" =3D 0 (%p)", server);
-	return 0;
+	list_add_tail(&server->link, &cell->servers);
+
+	write_unlock(&cell->servers_lock);
+	_leave(" =3D %p{%d}", server, atomic_read(&server->usage));
+	return server;
+
+	/* found a matching server quickly */
+found_server_quickly:
+	_debug("found quickly");
+	afs_get_server(server);
+	read_unlock(&cell->servers_lock);
+no_longer_unused:
+	if (!list_empty(&server->grave)) {
+		spin_lock(&afs_server_graveyard_lock);
+		list_del_init(&server->grave);
+		spin_unlock(&afs_server_graveyard_lock);
+	}
+	_leave(" =3D %p{%d}", server, atomic_read(&server->usage));
+	return server;
+
+	/* found a matching server on the second pass */
+found_server:
+	_debug("found");
+	afs_get_server(server);
+	write_unlock(&cell->servers_lock);
+	kfree(candidate);
+	goto no_longer_unused;
+
+	/* found a server that seems to be in two cells */
+server_in_two_cells:
+	write_unlock(&cell->servers_lock);
+	kfree(candidate);
+	printk(KERN_NOTICE "kAFS:"
+	       " Server "NIPQUAD_FMT" appears to be in two cells\n",
+	       NIPQUAD(*addr));
+	_leave(" =3D -EEXIST");
+	return ERR_PTR(-EEXIST);
+}
=20
-	/* found a matching active server */
-use_active_server:
-	_debug("active server");
-	afs_get_server(active);
-	write_unlock(&cell->sv_lock);
+/*
+ * look up a server by its IP address
+ */
+struct afs_server *afs_find_server(const struct in_addr *_addr)
+{
+	struct afs_server *server =3D NULL;
+	struct rb_node *p;
+	struct in_addr addr =3D *_addr;
=20
-	kfree(server);
+	_enter(NIPQUAD_FMT, NIPQUAD(addr.s_addr));
=20
-	*_server =3D active;
-	_leave(" =3D 0 (%p)", active);
-	return 0;
+	read_lock(&afs_servers_lock);
=20
-	/* found a matching server in the graveyard, so resurrect it and
-	 * dispose of the new record */
-resurrect_server:
-	_debug("resurrecting server");
+	p =3D afs_servers.rb_node;
+	while (p) {
+		server =3D rb_entry(p, struct afs_server, master_rb);
=20
-	list_move_tail(&zombie->link, &cell->sv_list);
-	afs_get_server(zombie);
-	afs_kafstimod_del_timer(&zombie->timeout);
-	spin_unlock(&cell->sv_gylock);
-	write_unlock(&cell->sv_lock);
+		_debug("- consider %p", p);
=20
-	kfree(server);
+		if (addr.s_addr < server->addr.s_addr) {
+			p =3D p->rb_left;
+		} else if (addr.s_addr > server->addr.s_addr) {
+			p =3D p->rb_right;
+		} else {
+			afs_get_server(server);
+			goto found;
+		}
+	}
=20
-	*_server =3D zombie;
-	_leave(" =3D 0 (%p)", zombie);
-	return 0;
+	server =3D NULL;
+found:
+	read_unlock(&afs_servers_lock);
+	ASSERTIFCMP(server, server->addr.s_addr, =3D=3D, addr.s_addr);
+	_leave(" =3D %p", server);
+	return server;
 }
=20
 /*
@@ -140,347 +218,105 @@ resurrect_server:
  */
 void afs_put_server(struct afs_server *server)
 {
-	struct afs_cell *cell;
-
 	if (!server)
 		return;
=20
-	_enter("%p", server);
-
-	cell =3D server->cell;
-
-	/* sanity check */
-	BUG_ON(atomic_read(&server->usage) <=3D 0);
+	_enter("%p{%d}", server, atomic_read(&server->usage));
=20
-	/* to prevent a race, the decrement and the dequeue must be effective=
ly
-	 * atomic */
-	write_lock(&cell->sv_lock);
+	ASSERTCMP(atomic_read(&server->usage), >, 0);
=20
 	if (likely(!atomic_dec_and_test(&server->usage))) {
-		write_unlock(&cell->sv_lock);
 		_leave("");
 		return;
 	}
=20
-	spin_lock(&cell->sv_gylock);
-	list_move_tail(&server->link, &cell->sv_graveyard);
+	afs_flush_callback_breaks(server);
=20
-	/* time out in 10 secs */
-	afs_kafstimod_add_timer(&server->timeout, 10 * HZ);
-
-	spin_unlock(&cell->sv_gylock);
-	write_unlock(&cell->sv_lock);
-
-	_leave(" [killed]");
+	spin_lock(&afs_server_graveyard_lock);
+	if (atomic_read(&server->usage) =3D=3D 0) {
+		list_move_tail(&server->grave, &afs_server_graveyard);
+		server->time_of_death =3D get_seconds();
+		schedule_delayed_work(&afs_server_reaper,
+				      afs_server_timeout * HZ);
+	}
+	spin_unlock(&afs_server_graveyard_lock);
+	_leave(" [dead]");
 }
=20
 /*
- * timeout server record
- * - removes from the cell's graveyard if the usage count is zero
+ * destroy a dead server
  */
-void afs_server_do_timeout(struct afs_server *server)
+static void afs_destroy_server(struct afs_server *server)
 {
-	struct rxrpc_peer *peer;
-	struct afs_cell *cell;
-	int loop;
-
 	_enter("%p", server);
=20
-	cell =3D server->cell;
-
-	BUG_ON(atomic_read(&server->usage) < 0);
-
-	/* remove from graveyard if still dead */
-	spin_lock(&cell->vl_gylock);
-	if (atomic_read(&server->usage) =3D=3D 0)
-		list_del_init(&server->link);
-	else
-		server =3D NULL;
-	spin_unlock(&cell->vl_gylock);
-
-	if (!server) {
-		_leave("");
-		return; /* resurrected */
-	}
-
-	/* we can now destroy it properly */
-	afs_put_cell(cell);
-
-	/* uncross-point the structs under a global lock */
-	spin_lock(&afs_server_peer_lock);
-	peer =3D server->peer;
-	if (peer) {
-		server->peer =3D NULL;
-		peer->user =3D NULL;
-	}
-	spin_unlock(&afs_server_peer_lock);
-
-	/* finish cleaning up the server */
-	for (loop =3D AFS_SERVER_CONN_LIST_SIZE - 1; loop >=3D 0; loop--)
-		if (server->fs_conn[loop])
-			rxrpc_put_connection(server->fs_conn[loop]);
-
-	if (server->vlserver)
-		rxrpc_put_connection(server->vlserver);
+	ASSERTCMP(server->fs_vnodes.rb_node, =3D=3D, NULL);
+	ASSERTCMP(server->cb_promises.rb_node, =3D=3D, NULL);
+	ASSERTCMP(server->cb_break_head, =3D=3D, server->cb_break_tail);
+	ASSERTCMP(atomic_read(&server->cb_break_n), =3D=3D, 0);
=20
+	afs_put_cell(server->cell);
 	kfree(server);
-
-	_leave(" [destroyed]");
 }
=20
 /*
- * get a callslot on a connection to the fileserver on the specified s=
erver
+ * reap dead server records
  */
-int afs_server_request_callslot(struct afs_server *server,
-				struct afs_server_callslot *callslot)
+static void afs_reap_server(struct work_struct *work)
 {
-	struct afs_server_callslot *pcallslot;
-	struct rxrpc_connection *conn;
-	int nconn, ret;
-
-	_enter("%p,",server);
-
-	INIT_LIST_HEAD(&callslot->link);
-	callslot->task =3D current;
-	callslot->conn =3D NULL;
-	callslot->nconn =3D -1;
-	callslot->ready =3D 0;
-
-	ret =3D 0;
-	conn =3D NULL;
-
-	/* get hold of a callslot first */
-	spin_lock(&server->fs_lock);
-
-	/* resurrect the server if it's death timeout has expired */
-	if (server->fs_state) {
-		if (time_before(jiffies, server->fs_dead_jif)) {
-			ret =3D server->fs_state;
-			spin_unlock(&server->fs_lock);
-			_leave(" =3D %d [still dead]", ret);
-			return ret;
+	LIST_HEAD(corpses);
+	struct afs_server *server;
+	unsigned long delay, expiry;
+	time_t now;
+
+	now =3D get_seconds();
+	spin_lock(&afs_server_graveyard_lock);
+
+	while (!list_empty(&afs_server_graveyard)) {
+		server =3D list_entry(afs_server_graveyard.next,
+				    struct afs_server, grave);
+
+		/* the queue is ordered most dead first */
+		expiry =3D server->time_of_death + afs_server_timeout;
+		if (expiry > now) {
+			delay =3D (expiry - now) * HZ;
+			if (!schedule_delayed_work(&afs_server_reaper, delay)) {
+				cancel_delayed_work(&afs_server_reaper);
+				schedule_delayed_work(&afs_server_reaper,
+						      delay);
+			}
+			break;
 		}
=20
-		server->fs_state =3D 0;
-	}
-
-	/* try and find a connection that has spare callslots */
-	for (nconn =3D 0; nconn < AFS_SERVER_CONN_LIST_SIZE; nconn++) {
-		if (server->fs_conn_cnt[nconn] > 0) {
-			server->fs_conn_cnt[nconn]--;
-			spin_unlock(&server->fs_lock);
-			callslot->nconn =3D nconn;
-			goto obtained_slot;
+		write_lock(&server->cell->servers_lock);
+		write_lock(&afs_servers_lock);
+		if (atomic_read(&server->usage) > 0) {
+			list_del_init(&server->grave);
+		} else {
+			list_move_tail(&server->grave, &corpses);
+			list_del_init(&server->link);
+			rb_erase(&server->master_rb, &afs_servers);
 		}
+		write_unlock(&afs_servers_lock);
+		write_unlock(&server->cell->servers_lock);
 	}
=20
-	/* none were available - wait interruptibly for one to become
-	 * available */
-	set_current_state(TASK_INTERRUPTIBLE);
-	list_add_tail(&callslot->link, &server->fs_callq);
-	spin_unlock(&server->fs_lock);
-
-	while (!callslot->ready && !signal_pending(current)) {
-		schedule();
-		set_current_state(TASK_INTERRUPTIBLE);
-	}
-
-	set_current_state(TASK_RUNNING);
-
-	/* even if we were interrupted we may still be queued */
-	if (!callslot->ready) {
-		spin_lock(&server->fs_lock);
-		list_del_init(&callslot->link);
-		spin_unlock(&server->fs_lock);
-	}
-
-	nconn =3D callslot->nconn;
-
-	/* if interrupted, we must release any slot we also got before
-	 * returning an error */
-	if (signal_pending(current)) {
-		ret =3D -EINTR;
-		goto error_release;
-	}
-
-	/* if we were woken up with an error, then pass that error back to th=
e
-	 * called */
-	if (nconn < 0) {
-		_leave(" =3D %d", callslot->errno);
-		return callslot->errno;
-	}
-
-	/* were we given a connection directly? */
-	if (callslot->conn) {
-		/* yes - use it */
-		_leave(" =3D 0 (nc=3D%d)", nconn);
-		return 0;
-	}
+	spin_unlock(&afs_server_graveyard_lock);
=20
-	/* got a callslot, but no connection */
-obtained_slot:
-
-	/* need to get hold of the RxRPC connection */
-	down_write(&server->sem);
-
-	/* quick check to see if there's an outstanding error */
-	ret =3D server->fs_state;
-	if (ret)
-		goto error_release_upw;
-
-	if (server->fs_conn[nconn]) {
-		/* reuse an existing connection */
-		rxrpc_get_connection(server->fs_conn[nconn]);
-		callslot->conn =3D server->fs_conn[nconn];
-	} else {
-		/* create a new connection */
-		ret =3D rxrpc_create_connection(afs_transport,
-					      htons(7000),
-					      server->addr.s_addr,
-					      FS_SERVICE_ID,
-					      NULL,
-					      &server->fs_conn[nconn]);
-
-		if (ret < 0)
-			goto error_release_upw;
-
-		callslot->conn =3D server->fs_conn[0];
-		rxrpc_get_connection(callslot->conn);
+	/* now reap the corpses we've extracted */
+	while (!list_empty(&corpses)) {
+		server =3D list_entry(corpses.next, struct afs_server, grave);
+		list_del(&server->grave);
+		afs_destroy_server(server);
 	}
-
-	up_write(&server->sem);
-
- 	_leave(" =3D 0");
-	return 0;
-
-	/* handle an error occurring */
-error_release_upw:
-	up_write(&server->sem);
-
-error_release:
-	/* either release the callslot or pass it along to another deserving
-	 * task */
-	spin_lock(&server->fs_lock);
-
-	if (nconn < 0) {
-		/* no callslot allocated */
-	} else if (list_empty(&server->fs_callq)) {
-		/* no one waiting */
-		server->fs_conn_cnt[nconn]++;
-		spin_unlock(&server->fs_lock);
-	} else {
-		/* someone's waiting - dequeue them and wake them up */
-		pcallslot =3D list_entry(server->fs_callq.next,
-				       struct afs_server_callslot, link);
-		list_del_init(&pcallslot->link);
-
-		pcallslot->errno =3D server->fs_state;
-		if (!pcallslot->errno) {
-			/* pass them out callslot details */
-			callslot->conn =3D xchg(&pcallslot->conn,
-					      callslot->conn);
-			pcallslot->nconn =3D nconn;
-			callslot->nconn =3D nconn =3D -1;
-		}
-		pcallslot->ready =3D 1;
-		wake_up_process(pcallslot->task);
-		spin_unlock(&server->fs_lock);
-	}
-
-	rxrpc_put_connection(callslot->conn);
-	callslot->conn =3D NULL;
-
-	_leave(" =3D %d", ret);
-	return ret;
 }
=20
 /*
- * release a callslot back to the server
- * - transfers the RxRPC connection to the next pending callslot if po=
ssible
+ * discard all the server records for rmmod
  */
-void afs_server_release_callslot(struct afs_server *server,
-				 struct afs_server_callslot *callslot)
+void __exit afs_purge_servers(void)
 {
-	struct afs_server_callslot *pcallslot;
-
-	_enter("{ad=3D%08x,cnt=3D%u},{%d}",
-	       ntohl(server->addr.s_addr),
-	       server->fs_conn_cnt[callslot->nconn],
-	       callslot->nconn);
-
-	BUG_ON(callslot->nconn < 0);
-
-	spin_lock(&server->fs_lock);
-
-	if (list_empty(&server->fs_callq)) {
-		/* no one waiting */
-		server->fs_conn_cnt[callslot->nconn]++;
-		spin_unlock(&server->fs_lock);
-	} else {
-		/* someone's waiting - dequeue them and wake them up */
-		pcallslot =3D list_entry(server->fs_callq.next,
-				       struct afs_server_callslot, link);
-		list_del_init(&pcallslot->link);
-
-		pcallslot->errno =3D server->fs_state;
-		if (!pcallslot->errno) {
-			/* pass them out callslot details */
-			callslot->conn =3D xchg(&pcallslot->conn, callslot->conn);
-			pcallslot->nconn =3D callslot->nconn;
-			callslot->nconn =3D -1;
-		}
-
-		pcallslot->ready =3D 1;
-		wake_up_process(pcallslot->task);
-		spin_unlock(&server->fs_lock);
-	}
-
-	rxrpc_put_connection(callslot->conn);
-
-	_leave("");
-}
-
-/*
- * get a handle to a connection to the vlserver (volume location) on t=
he
- * specified server
- */
-int afs_server_get_vlconn(struct afs_server *server,
-			  struct rxrpc_connection **_conn)
-{
-	struct rxrpc_connection *conn;
-	int ret;
-
-	_enter("%p,", server);
-
-	ret =3D 0;
-	conn =3D NULL;
-	down_read(&server->sem);
-
-	if (server->vlserver) {
-		/* reuse an existing connection */
-		rxrpc_get_connection(server->vlserver);
-		conn =3D server->vlserver;
-		up_read(&server->sem);
-	} else {
-		/* create a new connection */
-		up_read(&server->sem);
-		down_write(&server->sem);
-		if (!server->vlserver) {
-			ret =3D rxrpc_create_connection(afs_transport,
-						      htons(7003),
-						      server->addr.s_addr,
-						      VL_SERVICE_ID,
-						      NULL,
-						      &server->vlserver);
-		}
-		if (ret =3D=3D 0) {
-			rxrpc_get_connection(server->vlserver);
-			conn =3D server->vlserver;
-		}
-		up_write(&server->sem);
-	}
-
-	*_conn =3D conn;
-	_leave(" =3D %d", ret);
-	return ret;
+	afs_server_timeout =3D 0;
+	cancel_delayed_work(&afs_server_reaper);
+	schedule_delayed_work(&afs_server_reaper, 0);
 }
diff --git a/fs/afs/server.h b/fs/afs/server.h
deleted file mode 100644
index e1a0068..0000000
--- a/fs/afs/server.h
+++ /dev/null
@@ -1,97 +0,0 @@
-/* AFS server record
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef AFS_SERVER_H
-#define AFS_SERVER_H
-
-#include "types.h"
-#include "kafstimod.h"
-#include <rxrpc/peer.h>
-#include <linux/rwsem.h>
-
-extern spinlock_t afs_server_peer_lock;
-
-/*
- * AFS server record
- */
-struct afs_server {
-	atomic_t		usage;
-	struct afs_cell		*cell;		/* cell in which server resides */
-	struct list_head	link;		/* link in cell's server list */
-	struct rw_semaphore	sem;		/* access lock */
-	struct afs_timer	timeout;	/* graveyard timeout */
-	struct in_addr		addr;		/* server address */
-	struct rxrpc_peer	*peer;		/* peer record for this server */
-	struct rxrpc_connection	*vlserver;	/* connection to the volume locati=
on service */
-
-	/* file service access */
-#define AFS_SERVER_CONN_LIST_SIZE 2
-	struct rxrpc_connection	*fs_conn[AFS_SERVER_CONN_LIST_SIZE]; /* FS co=
nnections */
-	unsigned		fs_conn_cnt[AFS_SERVER_CONN_LIST_SIZE];	/* per conn call co=
unt */
-	struct list_head	fs_callq;	/* queue of processes waiting to make a ca=
ll */
-	spinlock_t		fs_lock;	/* access lock */
-	int			fs_state;      	/* 0 or reason FS currently marked dead (-errno=
) */
-	unsigned		fs_rtt;		/* FS round trip time */
-	unsigned long		fs_act_jif;	/* time at which last activity occurred */
-	unsigned long		fs_dead_jif;	/* time at which no longer to be consider=
ed dead */
-
-	/* callback promise management */
-	struct list_head	cb_promises;	/* as yet unbroken promises from this s=
erver */
-	spinlock_t		cb_lock;	/* access lock */
-};
-
-extern int afs_server_lookup(struct afs_cell *, const struct in_addr *=
,
-			     struct afs_server **);
-
-#define afs_get_server(S) do { atomic_inc(&(S)->usage); } while(0)
-
-extern void afs_put_server(struct afs_server *);
-extern void afs_server_do_timeout(struct afs_server *);
-
-extern int afs_server_find_by_peer(const struct rxrpc_peer *,
-				   struct afs_server **);
-
-extern int afs_server_get_vlconn(struct afs_server *,
-				 struct rxrpc_connection **);
-
-static inline
-struct afs_server *afs_server_get_from_peer(struct rxrpc_peer *peer)
-{
-	struct afs_server *server;
-
-	spin_lock(&afs_server_peer_lock);
-	server =3D peer->user;
-	if (server)
-		afs_get_server(server);
-	spin_unlock(&afs_server_peer_lock);
-
-	return server;
-}
-
-/*
- * AFS server callslot grant record
- */
-struct afs_server_callslot {
-	struct list_head	link;		/* link in server's list */
-	struct task_struct	*task;		/* process waiting to make call */
-	struct rxrpc_connection	*conn;		/* connection to use (or NULL on erro=
r) */
-	short			nconn;		/* connection slot number (-1 on error) */
-	char			ready;		/* T when ready */
-	int			errno;		/* error number if nconn=3D=3D-1 */
-};
-
-extern int afs_server_request_callslot(struct afs_server *,
-				       struct afs_server_callslot *);
-
-extern void afs_server_release_callslot(struct afs_server *,
-					struct afs_server_callslot *);
-
-#endif /* AFS_SERVER_H */
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 0470a5c..efc4fe6 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -1,6 +1,6 @@
 /* AFS superblock handling
  *
- * Copyright (c) 2002 Red Hat, Inc. All rights reserved.
+ * Copyright (c) 2002, 2007 Red Hat, Inc. All rights reserved.
  *
  * This software may be freely redistributed under the terms of the
  * GNU General Public License.
@@ -20,12 +20,6 @@
 #include <linux/slab.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
-#include "vnode.h"
-#include "volume.h"
-#include "cell.h"
-#include "cmservice.h"
-#include "fsclient.h"
-#include "super.h"
 #include "internal.h"
=20
 #define AFS_FS_MAGIC 0x6B414653 /* 'kAFS' */
@@ -63,6 +57,7 @@ static const struct super_operations afs_super_ops =3D=
 {
 	.drop_inode	=3D generic_delete_inode,
 	.destroy_inode	=3D afs_destroy_inode,
 	.clear_inode	=3D afs_clear_inode,
+	.umount_begin	=3D afs_umount_begin,
 	.put_super	=3D afs_put_super,
 };
=20
@@ -78,8 +73,6 @@ int __init afs_fs_init(void)
=20
 	_enter("");
=20
-	afs_timer_init(&afs_mntpt_expiry_timer, &afs_mntpt_expiry_timer_ops);
-
 	/* create ourselves an inode cache */
 	atomic_set(&afs_count_active_inodes, 0);
=20
@@ -99,11 +92,11 @@ int __init afs_fs_init(void)
 	ret =3D register_filesystem(&afs_fs_type);
 	if (ret < 0) {
 		kmem_cache_destroy(afs_inode_cachep);
-		kleave(" =3D %d", ret);
+		_leave(" =3D %d", ret);
 		return ret;
 	}
=20
-	kleave(" =3D 0");
+	_leave(" =3D 0");
 	return 0;
 }
=20
@@ -112,6 +105,9 @@ int __init afs_fs_init(void)
  */
 void __exit afs_fs_exit(void)
 {
+	_enter("");
+
+	afs_mntpt_kill_timer();
 	unregister_filesystem(&afs_fs_type);
=20
 	if (atomic_read(&afs_count_active_inodes) !=3D 0) {
@@ -121,6 +117,7 @@ void __exit afs_fs_exit(void)
 	}
=20
 	kmem_cache_destroy(afs_inode_cachep);
+	_leave("");
 }
=20
 /*
@@ -154,9 +151,9 @@ static int want_no_value(char *const *_value, const=
 char *option)
  *   shamelessly adapted it from the msdos fs
  */
 static int afs_super_parse_options(struct afs_mount_params *params,
-				   char *options,
-				   const char **devname)
+				   char *options, const char **devname)
 {
+	struct afs_cell *cell;
 	char *key, *value;
 	int ret;
=20
@@ -165,43 +162,37 @@ static int afs_super_parse_options(struct afs_mou=
nt_params *params,
 	options[PAGE_SIZE - 1] =3D 0;
=20
 	ret =3D 0;
-	while ((key =3D strsep(&options, ",")) !=3D 0)
-	{
+	while ((key =3D strsep(&options, ","))) {
 		value =3D strchr(key, '=3D');
 		if (value)
 			*value++ =3D 0;
=20
-		printk("kAFS: KEY: %s, VAL:%s\n", key, value ?: "-");
+		_debug("kAFS: KEY: %s, VAL:%s", key, value ?: "-");
=20
 		if (strcmp(key, "rwpath") =3D=3D 0) {
 			if (!want_no_value(&value, "rwpath"))
 				return -EINVAL;
 			params->rwpath =3D 1;
-			continue;
 		} else if (strcmp(key, "vol") =3D=3D 0) {
 			if (!want_arg(&value, "vol"))
 				return -EINVAL;
 			*devname =3D value;
-			continue;
 		} else if (strcmp(key, "cell") =3D=3D 0) {
 			if (!want_arg(&value, "cell"))
 				return -EINVAL;
+			cell =3D afs_cell_lookup(value, strlen(value));
+			if (IS_ERR(cell))
+				return PTR_ERR(cell);
 			afs_put_cell(params->default_cell);
-			ret =3D afs_cell_lookup(value,
-					      strlen(value),
-					      &params->default_cell);
-			if (ret < 0)
-				return -EINVAL;
-			continue;
+			params->default_cell =3D cell;
+		} else {
+			printk("kAFS: Unknown mount option: '%s'\n",  key);
+			ret =3D -EINVAL;
+			goto error;
 		}
-
-		printk("kAFS: Unknown mount option: '%s'\n",  key);
-		ret =3D -EINVAL;
-		goto error;
 	}
=20
 	ret =3D 0;
-
 error:
 	_leave(" =3D %d", ret);
 	return ret;
@@ -230,7 +221,7 @@ static int afs_fill_super(struct super_block *sb, v=
oid *data, int silent)
 	struct inode *inode =3D NULL;
 	int ret;
=20
-	kenter("");
+	_enter("");
=20
 	/* allocate a superblock info record */
 	as =3D kzalloc(sizeof(struct afs_super_info), GFP_KERNEL);
@@ -253,9 +244,9 @@ static int afs_fill_super(struct super_block *sb, v=
oid *data, int silent)
 	fid.vid		=3D as->volume->vid;
 	fid.vnode	=3D 1;
 	fid.unique	=3D 1;
-	ret =3D afs_iget(sb, &fid, &inode);
-	if (ret < 0)
-		goto error;
+	inode =3D afs_iget(sb, &fid);
+	if (IS_ERR(inode))
+		goto error_inode;
=20
 	ret =3D -ENOMEM;
 	root =3D d_alloc_root(inode);
@@ -264,9 +255,12 @@ static int afs_fill_super(struct super_block *sb, =
void *data, int silent)
=20
 	sb->s_root =3D root;
=20
-	kleave(" =3D 0");
+	_leave(" =3D 0");
 	return 0;
=20
+error_inode:
+	ret =3D PTR_ERR(inode);
+	inode =3D NULL;
 error:
 	iput(inode);
 	afs_put_volume(as->volume);
@@ -274,7 +268,7 @@ error:
=20
 	sb->s_fs_info =3D NULL;
=20
-	kleave(" =3D %d", ret);
+	_leave(" =3D %d", ret);
 	return ret;
 }
=20
@@ -290,19 +284,13 @@ static int afs_get_sb(struct file_system_type *fs=
_type,
 {
 	struct afs_mount_params params;
 	struct super_block *sb;
+	struct afs_volume *vol;
 	int ret;
=20
 	_enter(",,%s,%p", dev_name, options);
=20
 	memset(&params, 0, sizeof(params));
=20
-	/* start the cache manager */
-	ret =3D afscm_start();
-	if (ret < 0) {
-		_leave(" =3D %d", ret);
-		return ret;
-	}
-
 	/* parse the options */
 	if (options) {
 		ret =3D afs_super_parse_options(&params, options, &dev_name);
@@ -316,17 +304,20 @@ static int afs_get_sb(struct file_system_type *fs=
_type,
 	}
=20
 	/* parse the device name */
-	ret =3D afs_volume_lookup(dev_name,
-				params.default_cell,
-				params.rwpath,
-				&params.volume);
-	if (ret < 0)
+	vol =3D afs_volume_lookup(dev_name, params.default_cell, params.rwpat=
h);
+	if (IS_ERR(vol)) {
+		ret =3D PTR_ERR(vol);
 		goto error;
+	}
+
+	params.volume =3D vol;
=20
 	/* allocate a deviceless superblock */
 	sb =3D sget(fs_type, afs_test_super, set_anon_super, &params);
-	if (IS_ERR(sb))
+	if (IS_ERR(sb)) {
+		ret =3D PTR_ERR(sb);
 		goto error;
+	}
=20
 	sb->s_flags =3D flags;
=20
@@ -341,13 +332,12 @@ static int afs_get_sb(struct file_system_type *fs=
_type,
=20
 	afs_put_volume(params.volume);
 	afs_put_cell(params.default_cell);
-	_leave(" =3D 0 [%p]", 0, sb);
+	_leave(" =3D 0 [%p]", sb);
 	return 0;
=20
 error:
 	afs_put_volume(params.volume);
 	afs_put_cell(params.default_cell);
-	afscm_stop();
 	_leave(" =3D %d", ret);
 	return ret;
 }
@@ -362,7 +352,6 @@ static void afs_put_super(struct super_block *sb)
 	_enter("");
=20
 	afs_put_volume(as->volume);
-	afscm_stop();
=20
 	_leave("");
 }
@@ -381,10 +370,8 @@ static void afs_i_init_once(void *_vnode, struct k=
mem_cache *cachep,
 		inode_init_once(&vnode->vfs_inode);
 		init_waitqueue_head(&vnode->update_waitq);
 		spin_lock_init(&vnode->lock);
-		INIT_LIST_HEAD(&vnode->cb_link);
-		INIT_LIST_HEAD(&vnode->cb_hash_link);
-		afs_timer_init(&vnode->cb_timeout,
-			       &afs_vnode_cb_timed_out_ops);
+		INIT_WORK(&vnode->cb_broken_work, afs_broken_callback_work);
+		mutex_init(&vnode->cb_broken_lock);
 	}
 }
=20
@@ -407,6 +394,7 @@ static struct inode *afs_alloc_inode(struct super_b=
lock *sb)
 	vnode->volume		=3D NULL;
 	vnode->update_cnt	=3D 0;
 	vnode->flags		=3D 0;
+	vnode->cb_promised	=3D false;
=20
 	return &vnode->vfs_inode;
 }
@@ -416,8 +404,14 @@ static struct inode *afs_alloc_inode(struct super_=
block *sb)
  */
 static void afs_destroy_inode(struct inode *inode)
 {
+	struct afs_vnode *vnode =3D AFS_FS_I(inode);
+
 	_enter("{%lu}", inode->i_ino);
=20
-	kmem_cache_free(afs_inode_cachep, AFS_FS_I(inode));
+	_debug("DESTROY INODE %p", inode);
+
+	ASSERTCMP(vnode->server, =3D=3D, NULL);
+
+	kmem_cache_free(afs_inode_cachep, vnode);
 	atomic_dec(&afs_count_active_inodes);
 }
diff --git a/fs/afs/super.h b/fs/afs/super.h
deleted file mode 100644
index c95b48e..0000000
--- a/fs/afs/super.h
+++ /dev/null
@@ -1,39 +0,0 @@
-/* AFS filesystem internal private data
- *
- * Copyright (c) 2002 Red Hat, Inc. All rights reserved.
- *
- * This software may be freely redistributed under the terms of the
- * GNU General Public License.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- *
- * Authors: David Woodhouse <dwmw2@cambridge.redhat.com>
- *          David Howells <dhowells@redhat.com>
- *
- */
-
-#ifndef AFS_SUPER_H
-#define AFS_SUPER_H
-
-#include <linux/fs.h>
-#include "server.h"
-
-/*
- * AFS superblock private data
- * - there's one superblock per volume
- */
-struct afs_super_info {
-	struct afs_volume	*volume;	/* volume record */
-	char			rwparent;	/* T if parent is R/W AFS volume */
-};
-
-static inline struct afs_super_info *AFS_FS_S(struct super_block *sb)
-{
-	return sb->s_fs_info;
-}
-
-extern struct file_system_type afs_fs_type;
-
-#endif /* AFS_SUPER_H */
diff --git a/fs/afs/transport.h b/fs/afs/transport.h
deleted file mode 100644
index f56be4b..0000000
--- a/fs/afs/transport.h
+++ /dev/null
@@ -1,21 +0,0 @@
-/* AFS transport management
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef AFS_TRANSPORT_H
-#define AFS_TRANSPORT_H
-
-#include "types.h"
-#include <rxrpc/transport.h>
-
-/* the cache manager transport endpoint */
-extern struct rxrpc_transport *afs_transport;
-
-#endif /* AFS_TRANSPORT_H */
diff --git a/fs/afs/types.h b/fs/afs/types.h
deleted file mode 100644
index db2b5dc..0000000
--- a/fs/afs/types.h
+++ /dev/null
@@ -1,109 +0,0 @@
-/* AFS types
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef AFS_TYPES_H
-#define AFS_TYPES_H
-
-#include <rxrpc/types.h>
-
-typedef unsigned			afs_volid_t;
-typedef unsigned			afs_vnodeid_t;
-typedef unsigned long long		afs_dataversion_t;
-
-typedef enum {
-	AFSVL_RWVOL,			/* read/write volume */
-	AFSVL_ROVOL,			/* read-only volume */
-	AFSVL_BACKVOL,			/* backup volume */
-} __attribute__((packed)) afs_voltype_t;
-
-typedef enum {
-	AFS_FTYPE_INVALID	=3D 0,
-	AFS_FTYPE_FILE		=3D 1,
-	AFS_FTYPE_DIR		=3D 2,
-	AFS_FTYPE_SYMLINK	=3D 3,
-} afs_file_type_t;
-
-struct afs_cell;
-struct afs_vnode;
-
-/*
- * AFS file identifier
- */
-struct afs_fid {
-	afs_volid_t	vid;		/* volume ID */
-	afs_vnodeid_t	vnode;		/* file index within volume */
-	unsigned	unique;		/* unique ID number (file index version) */
-};
-
-/*
- * AFS callback notification
- */
-typedef enum {
-	AFSCM_CB_UNTYPED	=3D 0,	/* no type set on CB break */
-	AFSCM_CB_EXCLUSIVE	=3D 1,	/* CB exclusive to CM [not implemented] */
-	AFSCM_CB_SHARED		=3D 2,	/* CB shared by other CM's */
-	AFSCM_CB_DROPPED	=3D 3,	/* CB promise cancelled by file server */
-} afs_callback_type_t;
-
-struct afs_callback {
-	struct afs_server	*server;	/* server that made the promise */
-	struct afs_fid		fid;		/* file identifier */
-	unsigned		version;	/* callback version */
-	unsigned		expiry;		/* time at which expires */
-	afs_callback_type_t	type;		/* type of callback */
-};
-
-#define AFSCBMAX 50
-
-/*
- * AFS volume information
- */
-struct afs_volume_info {
-	afs_volid_t		vid;		/* volume ID */
-	afs_voltype_t		type;		/* type of this volume */
-	afs_volid_t		type_vids[5];	/* volume ID's for possible types for this=
 vol */
-=09
-	/* list of fileservers serving this volume */
-	size_t			nservers;	/* number of entries used in servers[] */
-	struct {
-		struct in_addr	addr;		/* fileserver address */
-	} servers[8];
-};
-
-/*
- * AFS file status information
- */
-struct afs_file_status {
-	unsigned		if_version;	/* interface version */
-#define AFS_FSTATUS_VERSION	1
-
-	afs_file_type_t		type;		/* file type */
-	unsigned		nlink;		/* link count */
-	size_t			size;		/* file size */
-	afs_dataversion_t	version;	/* current data version */
-	unsigned		author;		/* author ID */
-	unsigned		owner;		/* owner ID */
-	unsigned		caller_access;	/* access rights for authenticated caller */
-	unsigned		anon_access;	/* access rights for unauthenticated caller */
-	umode_t			mode;		/* UNIX mode */
-	struct afs_fid		parent;		/* parent file ID */
-	time_t			mtime_client;	/* last time client changed data */
-	time_t			mtime_server;	/* last time server changed data */
-};
-
-/*
- * AFS volume synchronisation information
- */
-struct afs_volsync {
-	time_t			creation;	/* volume creation time */
-};
-
-#endif /* AFS_TYPES_H */
diff --git a/fs/afs/vlclient.c b/fs/afs/vlclient.c
index dac9faa..0c7eba1 100644
--- a/fs/afs/vlclient.c
+++ b/fs/afs/vlclient.c
@@ -11,243 +11,76 @@
=20
 #include <linux/init.h>
 #include <linux/sched.h>
-#include <rxrpc/rxrpc.h>
-#include <rxrpc/transport.h>
-#include <rxrpc/connection.h>
-#include <rxrpc/call.h>
-#include "server.h"
-#include "volume.h"
-#include "vlclient.h"
-#include "kafsasyncd.h"
-#include "kafstimod.h"
-#include "errors.h"
 #include "internal.h"
=20
-#define VLGETENTRYBYID		503	/* AFS Get Cache Entry By ID operation ID =
*/
-#define VLGETENTRYBYNAME	504	/* AFS Get Cache Entry By Name operation =
ID */
-#define VLPROBE			514	/* AFS Probe Volume Location Service operation I=
D */
-
-static void afs_rxvl_get_entry_by_id_attn(struct rxrpc_call *call);
-static void afs_rxvl_get_entry_by_id_error(struct rxrpc_call *call);
-
 /*
- * map afs VL abort codes to/from Linux error codes
- * - called with call->lock held
+ * map volume locator abort codes to error codes
  */
-static void afs_rxvl_aemap(struct rxrpc_call *call)
+static int afs_vl_abort_to_error(u32 abort_code)
 {
-	int err;
-
-	_enter("{%u,%u,%d}",
-	       call->app_err_state, call->app_abort_code, call->app_errno);
-
-	switch (call->app_err_state) {
-	case RXRPC_ESTATE_LOCAL_ABORT:
-		call->app_abort_code =3D -call->app_errno;
-		return;
-
-	case RXRPC_ESTATE_PEER_ABORT:
-		switch (call->app_abort_code) {
-		case AFSVL_IDEXIST:		err =3D -EEXIST;		break;
-		case AFSVL_IO:			err =3D -EREMOTEIO;	break;
-		case AFSVL_NAMEEXIST:		err =3D -EEXIST;		break;
-		case AFSVL_CREATEFAIL:		err =3D -EREMOTEIO;	break;
-		case AFSVL_NOENT:		err =3D -ENOMEDIUM;	break;
-		case AFSVL_EMPTY:		err =3D -ENOMEDIUM;	break;
-		case AFSVL_ENTDELETED:		err =3D -ENOMEDIUM;	break;
-		case AFSVL_BADNAME:		err =3D -EINVAL;		break;
-		case AFSVL_BADINDEX:		err =3D -EINVAL;		break;
-		case AFSVL_BADVOLTYPE:		err =3D -EINVAL;		break;
-		case AFSVL_BADSERVER:		err =3D -EINVAL;		break;
-		case AFSVL_BADPARTITION:	err =3D -EINVAL;		break;
-		case AFSVL_REPSFULL:		err =3D -EFBIG;		break;
-		case AFSVL_NOREPSERVER:		err =3D -ENOENT;		break;
-		case AFSVL_DUPREPSERVER:	err =3D -EEXIST;		break;
-		case AFSVL_RWNOTFOUND:		err =3D -ENOENT;		break;
-		case AFSVL_BADREFCOUNT:		err =3D -EINVAL;		break;
-		case AFSVL_SIZEEXCEEDED:	err =3D -EINVAL;		break;
-		case AFSVL_BADENTRY:		err =3D -EINVAL;		break;
-		case AFSVL_BADVOLIDBUMP:	err =3D -EINVAL;		break;
-		case AFSVL_IDALREADYHASHED:	err =3D -EINVAL;		break;
-		case AFSVL_ENTRYLOCKED:		err =3D -EBUSY;		break;
-		case AFSVL_BADVOLOPER:		err =3D -EBADRQC;		break;
-		case AFSVL_BADRELLOCKTYPE:	err =3D -EINVAL;		break;
-		case AFSVL_RERELEASE:		err =3D -EREMOTEIO;	break;
-		case AFSVL_BADSERVERFLAG:	err =3D -EINVAL;		break;
-		case AFSVL_PERM:		err =3D -EACCES;		break;
-		case AFSVL_NOMEM:		err =3D -EREMOTEIO;	break;
-		default:
-			err =3D afs_abort_to_error(call->app_abort_code);
-			break;
-		}
-		call->app_errno =3D err;
-		return;
-
+	_enter("%u", abort_code);
+
+	switch (abort_code) {
+	case AFSVL_IDEXIST:		return -EEXIST;
+	case AFSVL_IO:			return -EREMOTEIO;
+	case AFSVL_NAMEEXIST:		return -EEXIST;
+	case AFSVL_CREATEFAIL:		return -EREMOTEIO;
+	case AFSVL_NOENT:		return -ENOMEDIUM;
+	case AFSVL_EMPTY:		return -ENOMEDIUM;
+	case AFSVL_ENTDELETED:		return -ENOMEDIUM;
+	case AFSVL_BADNAME:		return -EINVAL;
+	case AFSVL_BADINDEX:		return -EINVAL;
+	case AFSVL_BADVOLTYPE:		return -EINVAL;
+	case AFSVL_BADSERVER:		return -EINVAL;
+	case AFSVL_BADPARTITION:	return -EINVAL;
+	case AFSVL_REPSFULL:		return -EFBIG;
+	case AFSVL_NOREPSERVER:		return -ENOENT;
+	case AFSVL_DUPREPSERVER:	return -EEXIST;
+	case AFSVL_RWNOTFOUND:		return -ENOENT;
+	case AFSVL_BADREFCOUNT:		return -EINVAL;
+	case AFSVL_SIZEEXCEEDED:	return -EINVAL;
+	case AFSVL_BADENTRY:		return -EINVAL;
+	case AFSVL_BADVOLIDBUMP:	return -EINVAL;
+	case AFSVL_IDALREADYHASHED:	return -EINVAL;
+	case AFSVL_ENTRYLOCKED:		return -EBUSY;
+	case AFSVL_BADVOLOPER:		return -EBADRQC;
+	case AFSVL_BADRELLOCKTYPE:	return -EINVAL;
+	case AFSVL_RERELEASE:		return -EREMOTEIO;
+	case AFSVL_BADSERVERFLAG:	return -EINVAL;
+	case AFSVL_PERM:		return -EACCES;
+	case AFSVL_NOMEM:		return -EREMOTEIO;
 	default:
-		return;
+		return afs_abort_to_error(abort_code);
 	}
 }
=20
-#if 0
 /*
- * probe a volume location server to see if it is still alive -- unuse=
d
+ * deliver reply data to a VL.GetEntryByXXX call
  */
-static int afs_rxvl_probe(struct afs_server *server, int alloc_flags)
+static int afs_deliver_vl_get_entry_by_xxx(struct afs_call *call,
+					   struct sk_buff *skb, bool last)
 {
-	struct rxrpc_connection *conn;
-	struct rxrpc_call *call;
-	struct kvec piov[1];
-	size_t sent;
-	int ret;
-	__be32 param[1];
-
-	DECLARE_WAITQUEUE(myself, current);
-
-	/* get hold of the vlserver connection */
-	ret =3D afs_server_get_vlconn(server, &conn);
-	if (ret < 0)
-		goto out;
-
-	/* create a call through that connection */
-	ret =3D rxrpc_create_call(conn, NULL, NULL, afs_rxvl_aemap, &call);
-	if (ret < 0) {
-		printk("kAFS: Unable to create call: %d\n", ret);
-		goto out_put_conn;
-	}
-	call->app_opcode =3D VLPROBE;
-
-	/* we want to get event notifications from the call */
-	add_wait_queue(&call->waitq, &myself);
-
-	/* marshall the parameters */
-	param[0] =3D htonl(VLPROBE);
-	piov[0].iov_len =3D sizeof(param);
-	piov[0].iov_base =3D param;
-
-	/* send the parameters to the server */
-	ret =3D rxrpc_call_write_data(call, 1, piov, RXRPC_LAST_PACKET,
-				    alloc_flags, 0, &sent);
-	if (ret < 0)
-		goto abort;
-
-	/* wait for the reply to completely arrive */
-	for (;;) {
-		set_current_state(TASK_INTERRUPTIBLE);
-		if (call->app_call_state !=3D RXRPC_CSTATE_CLNT_RCV_REPLY ||
-		    signal_pending(current))
-			break;
-		schedule();
-	}
-	set_current_state(TASK_RUNNING);
-
-	ret =3D -EINTR;
-	if (signal_pending(current))
-		goto abort;
-
-	switch (call->app_call_state) {
-	case RXRPC_CSTATE_ERROR:
-		ret =3D call->app_errno;
-		goto out_unwait;
-
-	case RXRPC_CSTATE_CLNT_GOT_REPLY:
-		ret =3D 0;
-		goto out_unwait;
-
-	default:
-		BUG();
-	}
+	struct afs_cache_vlocation *entry;
+	__be32 *bp;
+	u32 tmp;
+	int loop;
=20
-abort:
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	rxrpc_call_abort(call, ret);
-	schedule();
-
-out_unwait:
-	set_current_state(TASK_RUNNING);
-	remove_wait_queue(&call->waitq, &myself);
-	rxrpc_put_call(call);
-out_put_conn:
-	rxrpc_put_connection(conn);
-out:
-	return ret;
-}
-#endif
+	_enter(",,%u", last);
=20
-/*
- * look up a volume location database entry by name
- */
-int afs_rxvl_get_entry_by_name(struct afs_server *server,
-			       const char *volname,
-			       unsigned volnamesz,
-			       struct afs_cache_vlocation *entry)
-{
-	DECLARE_WAITQUEUE(myself, current);
-
-	struct rxrpc_connection *conn;
-	struct rxrpc_call *call;
-	struct kvec piov[3];
-	unsigned tmp;
-	size_t sent;
-	int ret, loop;
-	__be32 *bp, param[2], zero;
-
-	_enter(",%*.*s,%u,", volnamesz, volnamesz, volname, volnamesz);
-
-	memset(entry, 0, sizeof(*entry));
-
-	/* get hold of the vlserver connection */
-	ret =3D afs_server_get_vlconn(server, &conn);
-	if (ret < 0)
-		goto out;
-
-	/* create a call through that connection */
-	ret =3D rxrpc_create_call(conn, NULL, NULL, afs_rxvl_aemap, &call);
-	if (ret < 0) {
-		printk("kAFS: Unable to create call: %d\n", ret);
-		goto out_put_conn;
-	}
-	call->app_opcode =3D VLGETENTRYBYNAME;
+	afs_transfer_reply(call, skb);
+	if (!last)
+		return 0;
=20
-	/* we want to get event notifications from the call */
-	add_wait_queue(&call->waitq, &myself);
+	if (call->reply_size !=3D call->reply_max)
+		return -EBADMSG;
=20
-	/* marshall the parameters */
-	piov[1].iov_len =3D volnamesz;
-	piov[1].iov_base =3D (char *) volname;
-
-	zero =3D 0;
-	piov[2].iov_len =3D (4 - (piov[1].iov_len & 3)) & 3;
-	piov[2].iov_base =3D &zero;
-
-	param[0] =3D htonl(VLGETENTRYBYNAME);
-	param[1] =3D htonl(piov[1].iov_len);
-
-	piov[0].iov_len =3D sizeof(param);
-	piov[0].iov_base =3D param;
-
-	/* send the parameters to the server */
-	ret =3D rxrpc_call_write_data(call, 3, piov, RXRPC_LAST_PACKET, GFP_N=
OFS,
-				    0, &sent);
-	if (ret < 0)
-		goto abort;
-
-	/* wait for the reply to completely arrive */
-	bp =3D rxrpc_call_alloc_scratch(call, 384);
-
-	ret =3D rxrpc_call_read_data(call, bp, 384,
-				   RXRPC_CALL_READ_BLOCK |
-				   RXRPC_CALL_READ_ALL);
-	if (ret < 0) {
-		if (ret =3D=3D -ECONNABORTED) {
-			ret =3D call->app_errno;
-			goto out_unwait;
-		}
-		goto abort;
-	}
+	/* unmarshall the reply once we've received all of it */
+	entry =3D call->reply;
+	bp =3D call->buffer;
=20
-	/* unmarshall the reply */
 	for (loop =3D 0; loop < 64; loop++)
 		entry->name[loop] =3D ntohl(*bp++);
+	entry->name[loop] =3D 0;
 	bp++; /* final NUL */
=20
 	bp++; /* type */
@@ -260,6 +93,7 @@ int afs_rxvl_get_entry_by_name(struct afs_server *se=
rver,
=20
 	for (loop =3D 0; loop < 8; loop++) {
 		tmp =3D ntohl(*bp++);
+		entry->srvtmask[loop] =3D 0;
 		if (tmp & AFS_VLSF_RWVOL)
 			entry->srvtmask[loop] |=3D AFS_VOL_VTM_RW;
 		if (tmp & AFS_VLSF_ROVOL)
@@ -275,409 +109,104 @@ int afs_rxvl_get_entry_by_name(struct afs_serve=
r *server,
 	bp++; /* clone ID */
=20
 	tmp =3D ntohl(*bp++); /* flags */
+	entry->vidmask =3D 0;
 	if (tmp & AFS_VLF_RWEXISTS)
 		entry->vidmask |=3D AFS_VOL_VTM_RW;
 	if (tmp & AFS_VLF_ROEXISTS)
 		entry->vidmask |=3D AFS_VOL_VTM_RO;
 	if (tmp & AFS_VLF_BACKEXISTS)
 		entry->vidmask |=3D AFS_VOL_VTM_BAK;
-
-	ret =3D -ENOMEDIUM;
 	if (!entry->vidmask)
-		goto abort;
-
-	/* success */
-	entry->rtime =3D get_seconds();
-	ret =3D 0;
-
-out_unwait:
-	set_current_state(TASK_RUNNING);
-	remove_wait_queue(&call->waitq, &myself);
-	rxrpc_put_call(call);
-out_put_conn:
-	rxrpc_put_connection(conn);
-out:
-	_leave(" =3D %d", ret);
-	return ret;
-
-abort:
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	rxrpc_call_abort(call, ret);
-	schedule();
-	goto out_unwait;
+		return -EBADMSG;
+
+	_leave(" =3D 0 [done]");
+	return 0;
 }
=20
 /*
- * look up a volume location database entry by ID
+ * VL.GetEntryByName operation type
  */
-int afs_rxvl_get_entry_by_id(struct afs_server *server,
-			     afs_volid_t volid,
-			     afs_voltype_t voltype,
-			     struct afs_cache_vlocation *entry)
-{
-	DECLARE_WAITQUEUE(myself, current);
-
-	struct rxrpc_connection *conn;
-	struct rxrpc_call *call;
-	struct kvec piov[1];
-	unsigned tmp;
-	size_t sent;
-	int ret, loop;
-	__be32 *bp, param[3];
-
-	_enter(",%x,%d,", volid, voltype);
-
-	memset(entry, 0, sizeof(*entry));
-
-	/* get hold of the vlserver connection */
-	ret =3D afs_server_get_vlconn(server, &conn);
-	if (ret < 0)
-		goto out;
-
-	/* create a call through that connection */
-	ret =3D rxrpc_create_call(conn, NULL, NULL, afs_rxvl_aemap, &call);
-	if (ret < 0) {
-		printk("kAFS: Unable to create call: %d\n", ret);
-		goto out_put_conn;
-	}
-	call->app_opcode =3D VLGETENTRYBYID;
-
-	/* we want to get event notifications from the call */
-	add_wait_queue(&call->waitq, &myself);
-
-	/* marshall the parameters */
-	param[0] =3D htonl(VLGETENTRYBYID);
-	param[1] =3D htonl(volid);
-	param[2] =3D htonl(voltype);
-
-	piov[0].iov_len =3D sizeof(param);
-	piov[0].iov_base =3D param;
-
-	/* send the parameters to the server */
-	ret =3D rxrpc_call_write_data(call, 1, piov, RXRPC_LAST_PACKET, GFP_N=
OFS,
-				    0, &sent);
-	if (ret < 0)
-		goto abort;
-
-	/* wait for the reply to completely arrive */
-	bp =3D rxrpc_call_alloc_scratch(call, 384);
-
-	ret =3D rxrpc_call_read_data(call, bp, 384,
-				   RXRPC_CALL_READ_BLOCK |
-				   RXRPC_CALL_READ_ALL);
-	if (ret < 0) {
-		if (ret =3D=3D -ECONNABORTED) {
-			ret =3D call->app_errno;
-			goto out_unwait;
-		}
-		goto abort;
-	}
-
-	/* unmarshall the reply */
-	for (loop =3D 0; loop < 64; loop++)
-		entry->name[loop] =3D ntohl(*bp++);
-	bp++; /* final NUL */
-
-	bp++; /* type */
-	entry->nservers =3D ntohl(*bp++);
-
-	for (loop =3D 0; loop < 8; loop++)
-		entry->servers[loop].s_addr =3D *bp++;
-
-	bp +=3D 8; /* partition IDs */
-
-	for (loop =3D 0; loop < 8; loop++) {
-		tmp =3D ntohl(*bp++);
-		if (tmp & AFS_VLSF_RWVOL)
-			entry->srvtmask[loop] |=3D AFS_VOL_VTM_RW;
-		if (tmp & AFS_VLSF_ROVOL)
-			entry->srvtmask[loop] |=3D AFS_VOL_VTM_RO;
-		if (tmp & AFS_VLSF_BACKVOL)
-			entry->srvtmask[loop] |=3D AFS_VOL_VTM_BAK;
-	}
-
-	entry->vid[0] =3D ntohl(*bp++);
-	entry->vid[1] =3D ntohl(*bp++);
-	entry->vid[2] =3D ntohl(*bp++);
-
-	bp++; /* clone ID */
-
-	tmp =3D ntohl(*bp++); /* flags */
-	if (tmp & AFS_VLF_RWEXISTS)
-		entry->vidmask |=3D AFS_VOL_VTM_RW;
-	if (tmp & AFS_VLF_ROEXISTS)
-		entry->vidmask |=3D AFS_VOL_VTM_RO;
-	if (tmp & AFS_VLF_BACKEXISTS)
-		entry->vidmask |=3D AFS_VOL_VTM_BAK;
+static const struct afs_call_type afs_RXVLGetEntryByName =3D {
+	.deliver	=3D afs_deliver_vl_get_entry_by_xxx,
+	.abort_to_error	=3D afs_vl_abort_to_error,
+	.destructor	=3D afs_flat_call_destructor,
+};
=20
-	ret =3D -ENOMEDIUM;
-	if (!entry->vidmask)
-		goto abort;
-
-#if 0 /* TODO: remove */
-	entry->nservers =3D 3;
-	entry->servers[0].s_addr =3D htonl(0xac101249);
-	entry->servers[1].s_addr =3D htonl(0xac101243);
-	entry->servers[2].s_addr =3D htonl(0xac10125b /*0xac10125b*/);
-
-	entry->srvtmask[0] =3D AFS_VOL_VTM_RO;
-	entry->srvtmask[1] =3D AFS_VOL_VTM_RO;
-	entry->srvtmask[2] =3D AFS_VOL_VTM_RO | AFS_VOL_VTM_RW;
-#endif
-
-	/* success */
-	entry->rtime =3D get_seconds();
-	ret =3D 0;
-
-out_unwait:
-	set_current_state(TASK_RUNNING);
-	remove_wait_queue(&call->waitq, &myself);
-	rxrpc_put_call(call);
-out_put_conn:
-	rxrpc_put_connection(conn);
-out:
-	_leave(" =3D %d", ret);
-	return ret;
-
-abort:
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	rxrpc_call_abort(call, ret);
-	schedule();
-	goto out_unwait;
-}
+/*
+ * VL.GetEntryById operation type
+ */
+static const struct afs_call_type afs_RXVLGetEntryById =3D {
+	.deliver	=3D afs_deliver_vl_get_entry_by_xxx,
+	.abort_to_error	=3D afs_vl_abort_to_error,
+	.destructor	=3D afs_flat_call_destructor,
+};
=20
 /*
- * look up a volume location database entry by ID asynchronously
+ * dispatch a get volume entry by name operation
  */
-int afs_rxvl_get_entry_by_id_async(struct afs_async_op *op,
-				   afs_volid_t volid,
-				   afs_voltype_t voltype)
+int afs_vl_get_entry_by_name(struct in_addr *addr,
+			     const char *volname,
+			     struct afs_cache_vlocation *entry,
+			     const struct afs_wait_mode *wait_mode)
 {
-	struct rxrpc_connection *conn;
-	struct rxrpc_call *call;
-	struct kvec piov[1];
-	size_t sent;
-	int ret;
-	__be32 param[3];
-
-	_enter(",%x,%d,", volid, voltype);
-
-	/* get hold of the vlserver connection */
-	ret =3D afs_server_get_vlconn(op->server, &conn);
-	if (ret < 0) {
-		_leave(" =3D %d", ret);
-		return ret;
-	}
+	struct afs_call *call;
+	size_t volnamesz, reqsz, padsz;
+	__be32 *bp;
=20
-	/* create a call through that connection */
-	ret =3D rxrpc_create_call(conn,
-				afs_rxvl_get_entry_by_id_attn,
-				afs_rxvl_get_entry_by_id_error,
-				afs_rxvl_aemap,
-				&op->call);
-	rxrpc_put_connection(conn);
-
-	if (ret < 0) {
-		printk("kAFS: Unable to create call: %d\n", ret);
-		_leave(" =3D %d", ret);
-		return ret;
-	}
+	_enter("");
=20
-	op->call->app_opcode =3D VLGETENTRYBYID;
-	op->call->app_user =3D op;
+	volnamesz =3D strlen(volname);
+	padsz =3D (4 - (volnamesz & 3)) & 3;
+	reqsz =3D 8 + volnamesz + padsz;
=20
-	call =3D op->call;
-	rxrpc_get_call(call);
+	call =3D afs_alloc_flat_call(&afs_RXVLGetEntryByName, reqsz, 384);
+	if (!call)
+		return -ENOMEM;
=20
-	/* send event notifications from the call to kafsasyncd */
-	afs_kafsasyncd_begin_op(op);
+	call->reply =3D entry;
+	call->service_id =3D VL_SERVICE;
+	call->port =3D htons(AFS_VL_PORT);
=20
 	/* marshall the parameters */
-	param[0] =3D htonl(VLGETENTRYBYID);
-	param[1] =3D htonl(volid);
-	param[2] =3D htonl(voltype);
-
-	piov[0].iov_len =3D sizeof(param);
-	piov[0].iov_base =3D param;
-
-	/* allocate result read buffer in scratch space */
-	call->app_scr_ptr =3D rxrpc_call_alloc_scratch(op->call, 384);
-
-	/* send the parameters to the server */
-	ret =3D rxrpc_call_write_data(call, 1, piov, RXRPC_LAST_PACKET, GFP_N=
OFS,
-				    0, &sent);
-	if (ret < 0) {
-		rxrpc_call_abort(call, ret); /* handle from kafsasyncd */
-		ret =3D 0;
-		goto out;
-	}
-
-	/* wait for the reply to completely arrive */
-	ret =3D rxrpc_call_read_data(call, call->app_scr_ptr, 384, 0);
-	switch (ret) {
-	case 0:
-	case -EAGAIN:
-	case -ECONNABORTED:
-		ret =3D 0;
-		break;	/* all handled by kafsasyncd */
-
-	default:
-		rxrpc_call_abort(call, ret); /* make kafsasyncd handle it */
-		ret =3D 0;
-		break;
-	}
-
-out:
-	rxrpc_put_call(call);
-	_leave(" =3D %d", ret);
-	return ret;
+	bp =3D call->request;
+	*bp++ =3D htonl(VLGETENTRYBYNAME);
+	*bp++ =3D htonl(volnamesz);
+	memcpy(bp, volname, volnamesz);
+	if (padsz > 0)
+		memset((void *) bp + volnamesz, 0, padsz);
+
+	/* initiate the call */
+	return afs_make_call(addr, call, GFP_KERNEL, wait_mode);
 }
=20
 /*
- * attend to the asynchronous get VLDB entry by ID
+ * dispatch a get volume entry by ID operation
  */
-int afs_rxvl_get_entry_by_id_async2(struct afs_async_op *op,
-				    struct afs_cache_vlocation *entry)
+int afs_vl_get_entry_by_id(struct in_addr *addr,
+			   afs_volid_t volid,
+			   afs_voltype_t voltype,
+			   struct afs_cache_vlocation *entry,
+			   const struct afs_wait_mode *wait_mode)
 {
+	struct afs_call *call;
 	__be32 *bp;
-	__u32 tmp;
-	int loop, ret;
-
-	_enter("{op=3D%p cst=3D%u}", op, op->call->app_call_state);
-
-	memset(entry, 0, sizeof(*entry));
-
-	if (op->call->app_call_state =3D=3D RXRPC_CSTATE_COMPLETE) {
-		/* operation finished */
-		afs_kafsasyncd_terminate_op(op);
-
-		bp =3D op->call->app_scr_ptr;
-
-		/* unmarshall the reply */
-		for (loop =3D 0; loop < 64; loop++)
-			entry->name[loop] =3D ntohl(*bp++);
-		bp++; /* final NUL */
-
-		bp++; /* type */
-		entry->nservers =3D ntohl(*bp++);
-
-		for (loop =3D 0; loop < 8; loop++)
-			entry->servers[loop].s_addr =3D *bp++;
-
-		bp +=3D 8; /* partition IDs */
-
-		for (loop =3D 0; loop < 8; loop++) {
-			tmp =3D ntohl(*bp++);
-			if (tmp & AFS_VLSF_RWVOL)
-				entry->srvtmask[loop] |=3D AFS_VOL_VTM_RW;
-			if (tmp & AFS_VLSF_ROVOL)
-				entry->srvtmask[loop] |=3D AFS_VOL_VTM_RO;
-			if (tmp & AFS_VLSF_BACKVOL)
-				entry->srvtmask[loop] |=3D AFS_VOL_VTM_BAK;
-		}
-
-		entry->vid[0] =3D ntohl(*bp++);
-		entry->vid[1] =3D ntohl(*bp++);
-		entry->vid[2] =3D ntohl(*bp++);
-
-		bp++; /* clone ID */
-
-		tmp =3D ntohl(*bp++); /* flags */
-		if (tmp & AFS_VLF_RWEXISTS)
-			entry->vidmask |=3D AFS_VOL_VTM_RW;
-		if (tmp & AFS_VLF_ROEXISTS)
-			entry->vidmask |=3D AFS_VOL_VTM_RO;
-		if (tmp & AFS_VLF_BACKEXISTS)
-			entry->vidmask |=3D AFS_VOL_VTM_BAK;
-
-		ret =3D -ENOMEDIUM;
-		if (!entry->vidmask) {
-			rxrpc_call_abort(op->call, ret);
-			goto done;
-		}
-
-#if 0 /* TODO: remove */
-		entry->nservers =3D 3;
-		entry->servers[0].s_addr =3D htonl(0xac101249);
-		entry->servers[1].s_addr =3D htonl(0xac101243);
-		entry->servers[2].s_addr =3D htonl(0xac10125b /*0xac10125b*/);
-
-		entry->srvtmask[0] =3D AFS_VOL_VTM_RO;
-		entry->srvtmask[1] =3D AFS_VOL_VTM_RO;
-		entry->srvtmask[2] =3D AFS_VOL_VTM_RO | AFS_VOL_VTM_RW;
-#endif
-
-		/* success */
-		entry->rtime =3D get_seconds();
-		ret =3D 0;
-		goto done;
-	}
-
-	if (op->call->app_call_state =3D=3D RXRPC_CSTATE_ERROR) {
-		/* operation error */
-		ret =3D op->call->app_errno;
-		goto done;
-	}
-
-	_leave(" =3D -EAGAIN");
-	return -EAGAIN;
-
-done:
-	rxrpc_put_call(op->call);
-	op->call =3D NULL;
-	_leave(" =3D %d", ret);
-	return ret;
-}
-
-/*
- * handle attention events on an async get-entry-by-ID op
- * - called from krxiod
- */
-static void afs_rxvl_get_entry_by_id_attn(struct rxrpc_call *call)
-{
-	struct afs_async_op *op =3D call->app_user;
-
-	_enter("{op=3D%p cst=3D%u}", op, call->app_call_state);
-
-	switch (call->app_call_state) {
-	case RXRPC_CSTATE_COMPLETE:
-		afs_kafsasyncd_attend_op(op);
-		break;
-	case RXRPC_CSTATE_CLNT_RCV_REPLY:
-		if (call->app_async_read)
-			break;
-	case RXRPC_CSTATE_CLNT_GOT_REPLY:
-		if (call->app_read_count =3D=3D 0)
-			break;
-		printk("kAFS: Reply bigger than expected"
-		       " {cst=3D%u asyn=3D%d mark=3D%Zu rdy=3D%Zu pr=3D%u%s}",
-		       call->app_call_state,
-		       call->app_async_read,
-		       call->app_mark,
-		       call->app_ready_qty,
-		       call->pkt_rcv_count,
-		       call->app_last_rcv ? " last" : "");
-
-		rxrpc_call_abort(call, -EBADMSG);
-		break;
-	default:
-		BUG();
-	}
=20
-	_leave("");
-}
+	_enter("");
=20
-/*
- * handle error events on an async get-entry-by-ID op
- * - called from krxiod
- */
-static void afs_rxvl_get_entry_by_id_error(struct rxrpc_call *call)
-{
-	struct afs_async_op *op =3D call->app_user;
+	call =3D afs_alloc_flat_call(&afs_RXVLGetEntryById, 12, 384);
+	if (!call)
+		return -ENOMEM;
=20
-	_enter("{op=3D%p cst=3D%u}", op, call->app_call_state);
+	call->reply =3D entry;
+	call->service_id =3D VL_SERVICE;
+	call->port =3D htons(AFS_VL_PORT);
=20
-	afs_kafsasyncd_attend_op(op);
+	/* marshall the parameters */
+	bp =3D call->request;
+	*bp++ =3D htonl(VLGETENTRYBYID);
+	*bp++ =3D htonl(volid);
+	*bp   =3D htonl(voltype);
=20
-	_leave("");
+	/* initiate the call */
+	return afs_make_call(addr, call, GFP_KERNEL, wait_mode);
 }
diff --git a/fs/afs/vlclient.h b/fs/afs/vlclient.h
deleted file mode 100644
index 11dc10f..0000000
--- a/fs/afs/vlclient.h
+++ /dev/null
@@ -1,85 +0,0 @@
-/* Volume Location Service client interface
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef AFS_VLCLIENT_H
-#define AFS_VLCLIENT_H
-
-#include "types.h"
-
-enum AFSVL_Errors {
-	AFSVL_IDEXIST 		=3D 363520,	/* Volume Id entry exists in vl database =
*/
-	AFSVL_IO 		=3D 363521,	/* I/O related error */
-	AFSVL_NAMEEXIST 	=3D 363522,	/* Volume name entry exists in vl databa=
se */
-	AFSVL_CREATEFAIL 	=3D 363523,	/* Internal creation failure */
-	AFSVL_NOENT 		=3D 363524,	/* No such entry */
-	AFSVL_EMPTY 		=3D 363525,	/* Vl database is empty */
-	AFSVL_ENTDELETED 	=3D 363526,	/* Entry is deleted (soft delete) */
-	AFSVL_BADNAME 		=3D 363527,	/* Volume name is illegal */
-	AFSVL_BADINDEX 		=3D 363528,	/* Index is out of range */
-	AFSVL_BADVOLTYPE 	=3D 363529,	/* Bad volume type */
-	AFSVL_BADSERVER 	=3D 363530,	/* Illegal server number (out of range) =
*/
-	AFSVL_BADPARTITION 	=3D 363531,	/* Bad partition number */
-	AFSVL_REPSFULL 		=3D 363532,	/* Run out of space for Replication site=
s */
-	AFSVL_NOREPSERVER 	=3D 363533,	/* No such Replication server site exi=
sts */
-	AFSVL_DUPREPSERVER 	=3D 363534,	/* Replication site already exists */
-	AFSVL_RWNOTFOUND 	=3D 363535,	/* Parent R/W entry not found */
-	AFSVL_BADREFCOUNT 	=3D 363536,	/* Illegal Reference Count number */
-	AFSVL_SIZEEXCEEDED 	=3D 363537,	/* Vl size for attributes exceeded */
-	AFSVL_BADENTRY 		=3D 363538,	/* Bad incoming vl entry */
-	AFSVL_BADVOLIDBUMP 	=3D 363539,	/* Illegal max volid increment */
-	AFSVL_IDALREADYHASHED 	=3D 363540,	/* RO/BACK id already hashed */
-	AFSVL_ENTRYLOCKED 	=3D 363541,	/* Vl entry is already locked */
-	AFSVL_BADVOLOPER 	=3D 363542,	/* Bad volume operation code */
-	AFSVL_BADRELLOCKTYPE 	=3D 363543,	/* Bad release lock type */
-	AFSVL_RERELEASE 	=3D 363544,	/* Status report: last release was abort=
ed */
-	AFSVL_BADSERVERFLAG 	=3D 363545,	/* Invalid replication site server =B0=
ag */
-	AFSVL_PERM 		=3D 363546,	/* No permission access */
-	AFSVL_NOMEM 		=3D 363547,	/* malloc/realloc failed to alloc enough me=
mory */
-};
-
-/* maps to "struct vldbentry" in vvl-spec.pdf */
-struct afs_vldbentry {
-	char		name[65];		/* name of volume (including NUL char) */
-	afs_voltype_t	type;			/* volume type */
-	unsigned	num_servers;		/* num servers that hold instances of this vol=
 */
-	unsigned	clone_id;		/* cloning ID */
-
-	unsigned	flags;
-#define AFS_VLF_RWEXISTS	0x1000		/* R/W volume exists */
-#define AFS_VLF_ROEXISTS	0x2000		/* R/O volume exists */
-#define AFS_VLF_BACKEXISTS	0x4000		/* backup volume exists */
-
-	afs_volid_t	volume_ids[3];		/* volume IDs */
-
-	struct {
-		struct in_addr	addr;		/* server address */
-		unsigned	partition;	/* partition ID on this server */
-		unsigned	flags;		/* server specific flags */
-#define AFS_VLSF_NEWREPSITE	0x0001	/* unused */
-#define AFS_VLSF_ROVOL		0x0002	/* this server holds a R/O instance of =
the volume */
-#define AFS_VLSF_RWVOL		0x0004	/* this server holds a R/W instance of =
the volume */
-#define AFS_VLSF_BACKVOL	0x0008	/* this server holds a backup instance=
 of the volume */
-	} servers[8];
-};
-
-extern int afs_rxvl_get_entry_by_name(struct afs_server *, const char =
*,
-				      unsigned, struct afs_cache_vlocation *);
-extern int afs_rxvl_get_entry_by_id(struct afs_server *, afs_volid_t,
-				    afs_voltype_t,
-				    struct afs_cache_vlocation *);
-
-extern int afs_rxvl_get_entry_by_id_async(struct afs_async_op *,
-					  afs_volid_t, afs_voltype_t);
-
-extern int afs_rxvl_get_entry_by_id_async2(struct afs_async_op *,
-					   struct afs_cache_vlocation *);
-
-#endif /* AFS_VLCLIENT_H */
diff --git a/fs/afs/vlocation.c b/fs/afs/vlocation.c
index e48728c..60cb2f4 100644
--- a/fs/afs/vlocation.c
+++ b/fs/afs/vlocation.c
@@ -1,6 +1,6 @@
-/* volume location management
+/* AFS volume location management
  *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2002, 2007 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -12,130 +12,60 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
-#include <linux/slab.h>
-#include <linux/fs.h>
-#include <linux/pagemap.h>
-#include "volume.h"
-#include "cell.h"
-#include "cmservice.h"
-#include "fsclient.h"
-#include "vlclient.h"
-#include "kafstimod.h"
-#include <rxrpc/connection.h>
 #include "internal.h"
=20
-#define AFS_VLDB_TIMEOUT HZ*1000
+unsigned afs_vlocation_timeout =3D 10;	/* volume location timeout in s=
econds */
+unsigned afs_vlocation_update_timeout =3D 10 * 60;
=20
-static void afs_vlocation_update_timer(struct afs_timer *timer);
-static void afs_vlocation_update_attend(struct afs_async_op *op);
-static void afs_vlocation_update_discard(struct afs_async_op *op);
-static void __afs_put_vlocation(struct afs_vlocation *vlocation);
+static void afs_vlocation_reaper(struct work_struct *);
+static void afs_vlocation_updater(struct work_struct *);
=20
-static void __afs_vlocation_timeout(struct afs_timer *timer)
-{
-	struct afs_vlocation *vlocation =3D
-		list_entry(timer, struct afs_vlocation, timeout);
-
-	_debug("VL TIMEOUT [%s{u=3D%d}]",
-	       vlocation->vldb.name, atomic_read(&vlocation->usage));
-
-	afs_vlocation_do_timeout(vlocation);
-}
-
-static const struct afs_timer_ops afs_vlocation_timer_ops =3D {
-	.timed_out	=3D __afs_vlocation_timeout,
-};
-
-static const struct afs_timer_ops afs_vlocation_update_timer_ops =3D {
-	.timed_out	=3D afs_vlocation_update_timer,
-};
-
-static const struct afs_async_op_ops afs_vlocation_update_op_ops =3D {
-	.attend		=3D afs_vlocation_update_attend,
-	.discard	=3D afs_vlocation_update_discard,
-};
-
-static LIST_HEAD(afs_vlocation_update_pendq);	/* queue of VLs awaiting=
 update */
-static struct afs_vlocation *afs_vlocation_update;	/* VL currently bei=
ng updated */
-static DEFINE_SPINLOCK(afs_vlocation_update_lock); /* lock guarding up=
date queue */
-
-#ifdef AFS_CACHING_SUPPORT
-static cachefs_match_val_t afs_vlocation_cache_match(void *target,
-						     const void *entry);
-static void afs_vlocation_cache_update(void *source, void *entry);
-
-struct cachefs_index_def afs_vlocation_cache_index_def =3D {
-	.name		=3D "vldb",
-	.data_size	=3D sizeof(struct afs_cache_vlocation),
-	.keys[0]	=3D { CACHEFS_INDEX_KEYS_ASCIIZ, 64 },
-	.match		=3D afs_vlocation_cache_match,
-	.update		=3D afs_vlocation_cache_update,
-};
-#endif
+static LIST_HEAD(afs_vlocation_updates);
+static LIST_HEAD(afs_vlocation_graveyard);
+static DEFINE_SPINLOCK(afs_vlocation_updates_lock);
+static DEFINE_SPINLOCK(afs_vlocation_graveyard_lock);
+static DECLARE_DELAYED_WORK(afs_vlocation_reap, afs_vlocation_reaper);
+static DECLARE_DELAYED_WORK(afs_vlocation_update, afs_vlocation_update=
r);
+static struct workqueue_struct *afs_vlocation_update_worker;
=20
 /*
  * iterate through the VL servers in a cell until one of them admits k=
nowing
  * about the volume in question
- * - caller must have cell->vl_sem write-locked
  */
-static int afs_vlocation_access_vl_by_name(struct afs_vlocation *vloca=
tion,
-					   const char *name,
-					   unsigned namesz,
+static int afs_vlocation_access_vl_by_name(struct afs_vlocation *vl,
 					   struct afs_cache_vlocation *vldb)
 {
-	struct afs_server *server =3D NULL;
-	struct afs_cell *cell =3D vlocation->cell;
+	struct afs_cell *cell =3D vl->cell;
+	struct in_addr addr;
 	int count, ret;
=20
-	_enter("%s,%*.*s,%u", cell->name, namesz, namesz, name, namesz);
+	_enter("%s,%s", cell->name, vl->vldb.name);
=20
+	down_write(&vl->cell->vl_sem);
 	ret =3D -ENOMEDIUM;
 	for (count =3D cell->vl_naddrs; count > 0; count--) {
-		_debug("CellServ[%hu]: %08x",
-		       cell->vl_curr_svix,
-		       cell->vl_addrs[cell->vl_curr_svix].s_addr);
-
-		/* try and create a server */
-		ret =3D afs_server_lookup(cell,
-					&cell->vl_addrs[cell->vl_curr_svix],
-					&server);
-		switch (ret) {
-		case 0:
-			break;
-		case -ENOMEM:
-		case -ENONET:
-			goto out;
-		default:
-			goto rotate;
-		}
+		addr =3D cell->vl_addrs[cell->vl_curr_svix];
+
+		_debug("CellServ[%hu]: %08x", cell->vl_curr_svix, addr.s_addr);
=20
 		/* attempt to access the VL server */
-		ret =3D afs_rxvl_get_entry_by_name(server, name, namesz, vldb);
+		ret =3D afs_vl_get_entry_by_name(&addr, vl->vldb.name, vldb,
+					       &afs_sync_call);
 		switch (ret) {
 		case 0:
-			afs_put_server(server);
 			goto out;
 		case -ENOMEM:
 		case -ENONET:
 		case -ENETUNREACH:
 		case -EHOSTUNREACH:
 		case -ECONNREFUSED:
-			down_write(&server->sem);
-			if (server->vlserver) {
-				rxrpc_put_connection(server->vlserver);
-				server->vlserver =3D NULL;
-			}
-			up_write(&server->sem);
-			afs_put_server(server);
 			if (ret =3D=3D -ENOMEM || ret =3D=3D -ENONET)
 				goto out;
 			goto rotate;
 		case -ENOMEDIUM:
-			afs_put_server(server);
 			goto out;
 		default:
-			afs_put_server(server);
-			ret =3D -ENOMEDIUM;
+			ret =3D -EIO;
 			goto rotate;
 		}
=20
@@ -146,6 +76,7 @@ static int afs_vlocation_access_vl_by_name(struct af=
s_vlocation *vlocation,
 	}
=20
 out:
+	up_write(&vl->cell->vl_sem);
 	_leave(" =3D %d", ret);
 	return ret;
 }
@@ -153,66 +84,56 @@ out:
 /*
  * iterate through the VL servers in a cell until one of them admits k=
nowing
  * about the volume in question
- * - caller must have cell->vl_sem write-locked
  */
-static int afs_vlocation_access_vl_by_id(struct afs_vlocation *vlocati=
on,
+static int afs_vlocation_access_vl_by_id(struct afs_vlocation *vl,
 					 afs_volid_t volid,
 					 afs_voltype_t voltype,
 					 struct afs_cache_vlocation *vldb)
 {
-	struct afs_server *server =3D NULL;
-	struct afs_cell *cell =3D vlocation->cell;
+	struct afs_cell *cell =3D vl->cell;
+	struct in_addr addr;
 	int count, ret;
=20
 	_enter("%s,%x,%d,", cell->name, volid, voltype);
=20
+	down_write(&vl->cell->vl_sem);
 	ret =3D -ENOMEDIUM;
 	for (count =3D cell->vl_naddrs; count > 0; count--) {
-		_debug("CellServ[%hu]: %08x",
-		       cell->vl_curr_svix,
-		       cell->vl_addrs[cell->vl_curr_svix].s_addr);
-
-		/* try and create a server */
-		ret =3D afs_server_lookup(cell,
-					&cell->vl_addrs[cell->vl_curr_svix],
-					&server);
-		switch (ret) {
-		case 0:
-			break;
-		case -ENOMEM:
-		case -ENONET:
-			goto out;
-		default:
-			goto rotate;
-		}
+		addr =3D cell->vl_addrs[cell->vl_curr_svix];
+
+		_debug("CellServ[%hu]: %08x", cell->vl_curr_svix, addr.s_addr);
=20
 		/* attempt to access the VL server */
-		ret =3D afs_rxvl_get_entry_by_id(server, volid, voltype, vldb);
+		ret =3D afs_vl_get_entry_by_id(&addr, volid, voltype, vldb,
+					     &afs_sync_call);
 		switch (ret) {
 		case 0:
-			afs_put_server(server);
 			goto out;
 		case -ENOMEM:
 		case -ENONET:
 		case -ENETUNREACH:
 		case -EHOSTUNREACH:
 		case -ECONNREFUSED:
-			down_write(&server->sem);
-			if (server->vlserver) {
-				rxrpc_put_connection(server->vlserver);
-				server->vlserver =3D NULL;
-			}
-			up_write(&server->sem);
-			afs_put_server(server);
 			if (ret =3D=3D -ENOMEM || ret =3D=3D -ENONET)
 				goto out;
 			goto rotate;
+		case -EBUSY:
+			vl->upd_busy_cnt++;
+			if (vl->upd_busy_cnt <=3D 3) {
+				if (vl->upd_busy_cnt > 1) {
+					/* second+ BUSY - sleep a little bit */
+					set_current_state(TASK_UNINTERRUPTIBLE);
+					schedule_timeout(1);
+					__set_current_state(TASK_RUNNING);
+				}
+				continue;
+			}
+			break;
 		case -ENOMEDIUM:
-			afs_put_server(server);
-			goto out;
+			vl->upd_rej_cnt++;
+			goto rotate;
 		default:
-			afs_put_server(server);
-			ret =3D -ENOMEDIUM;
+			ret =3D -EIO;
 			goto rotate;
 		}
=20
@@ -220,150 +141,83 @@ static int afs_vlocation_access_vl_by_id(struct =
afs_vlocation *vlocation,
 	rotate:
 		cell->vl_curr_svix++;
 		cell->vl_curr_svix %=3D cell->vl_naddrs;
+		vl->upd_busy_cnt =3D 0;
 	}
=20
 out:
+	if (ret < 0 && vl->upd_rej_cnt > 0) {
+		printk(KERN_NOTICE "kAFS:"
+		       " Active volume no longer valid '%s'\n",
+		       vl->vldb.name);
+		vl->valid =3D 0;
+		ret =3D -ENOMEDIUM;
+	}
+
+	up_write(&vl->cell->vl_sem);
 	_leave(" =3D %d", ret);
 	return ret;
 }
=20
 /*
- * lookup volume location
- * - caller must have cell->vol_sem write-locked
- * - iterate through the VL servers in a cell until one of them admits=
 knowing
- *   about the volume in question
- * - lookup in the local cache if not able to find on the VL server
- * - insert/update in the local cache if did get a VL response
+ * allocate a volume location record
  */
-int afs_vlocation_lookup(struct afs_cell *cell,
-			 const char *name,
-			 unsigned namesz,
-			 struct afs_vlocation **_vlocation)
+static struct afs_vlocation *afs_vlocation_alloc(struct afs_cell *cell=
,
+						 const char *name,
+						 size_t namesz)
 {
-	struct afs_cache_vlocation vldb;
-	struct afs_vlocation *vlocation;
-	afs_voltype_t voltype;
-	afs_volid_t vid;
-	int active =3D 0, ret;
-
-	_enter("{%s},%*.*s,%u,", cell->name, namesz, namesz, name, namesz);
-
-	if (namesz > sizeof(vlocation->vldb.name)) {
-		_leave(" =3D -ENAMETOOLONG");
-		return -ENAMETOOLONG;
-	}
-
-	/* search the cell's active list first */
-	list_for_each_entry(vlocation, &cell->vl_list, link) {
-		if (namesz < sizeof(vlocation->vldb.name) &&
-		    vlocation->vldb.name[namesz] !=3D '\0')
-			continue;
-
-		if (memcmp(vlocation->vldb.name, name, namesz) =3D=3D 0)
-			goto found_in_memory;
-	}
-
-	/* search the cell's graveyard list second */
-	spin_lock(&cell->vl_gylock);
-	list_for_each_entry(vlocation, &cell->vl_graveyard, link) {
-		if (namesz < sizeof(vlocation->vldb.name) &&
-		    vlocation->vldb.name[namesz] !=3D '\0')
-			continue;
-
-		if (memcmp(vlocation->vldb.name, name, namesz) =3D=3D 0)
-			goto found_in_graveyard;
-	}
-	spin_unlock(&cell->vl_gylock);
-
-	/* not in the cell's in-memory lists - create a new record */
-	vlocation =3D kzalloc(sizeof(struct afs_vlocation), GFP_KERNEL);
-	if (!vlocation)
-		return -ENOMEM;
-
-	atomic_set(&vlocation->usage, 1);
-	INIT_LIST_HEAD(&vlocation->link);
-	rwlock_init(&vlocation->lock);
-	memcpy(vlocation->vldb.name, name, namesz);
-
-	afs_timer_init(&vlocation->timeout, &afs_vlocation_timer_ops);
-	afs_timer_init(&vlocation->upd_timer, &afs_vlocation_update_timer_ops=
);
-	afs_async_op_init(&vlocation->upd_op, &afs_vlocation_update_op_ops);
-
-	afs_get_cell(cell);
-	vlocation->cell =3D cell;
-
-	list_add_tail(&vlocation->link, &cell->vl_list);
-
-#ifdef AFS_CACHING_SUPPORT
-	/* we want to store it in the cache, plus it might already be
-	 * encached */
-	cachefs_acquire_cookie(cell->cache,
-			       &afs_volume_cache_index_def,
-			       vlocation,
-			       &vlocation->cache);
-
-	if (vlocation->valid)
-		goto found_in_cache;
-#endif
-
-	/* try to look up an unknown volume in the cell VL databases by name =
*/
-	ret =3D afs_vlocation_access_vl_by_name(vlocation, name, namesz, &vld=
b);
-	if (ret < 0) {
-		printk("kAFS: failed to locate '%*.*s' in cell '%s'\n",
-		       namesz, namesz, name, cell->name);
-		goto error;
+	struct afs_vlocation *vl;
+
+	vl =3D kzalloc(sizeof(struct afs_vlocation), GFP_KERNEL);
+	if (vl) {
+		vl->cell =3D cell;
+		vl->state =3D AFS_VL_NEW;
+		atomic_set(&vl->usage, 1);
+		INIT_LIST_HEAD(&vl->link);
+		INIT_LIST_HEAD(&vl->grave);
+		INIT_LIST_HEAD(&vl->update);
+		init_waitqueue_head(&vl->waitq);
+		rwlock_init(&vl->lock);
+		memcpy(vl->vldb.name, name, namesz);
 	}
=20
-	goto found_on_vlserver;
-
-found_in_graveyard:
-	/* found in the graveyard - resurrect */
-	_debug("found in graveyard");
-	atomic_inc(&vlocation->usage);
-	list_move_tail(&vlocation->link, &cell->vl_list);
-	spin_unlock(&cell->vl_gylock);
-
-	afs_kafstimod_del_timer(&vlocation->timeout);
-	goto active;
-
-found_in_memory:
-	/* found in memory - check to see if it's active */
-	_debug("found in memory");
-	atomic_inc(&vlocation->usage);
+	_leave(" =3D %p", vl);
+	return vl;
+}
=20
-active:
-	active =3D 1;
+/*
+ * update record if we found it in the cache
+ */
+static int afs_vlocation_update_record(struct afs_vlocation *vl,
+				       struct afs_cache_vlocation *vldb)
+{
+	afs_voltype_t voltype;
+	afs_volid_t vid;
+	int ret;
=20
-#ifdef AFS_CACHING_SUPPORT
-found_in_cache:
-#endif
 	/* try to look up a cached volume in the cell VL databases by ID */
-	_debug("found in cache");
-
 	_debug("Locally Cached: %s %02x { %08x(%x) %08x(%x) %08x(%x) }",
-	       vlocation->vldb.name,
-	       vlocation->vldb.vidmask,
-	       ntohl(vlocation->vldb.servers[0].s_addr),
-	       vlocation->vldb.srvtmask[0],
-	       ntohl(vlocation->vldb.servers[1].s_addr),
-	       vlocation->vldb.srvtmask[1],
-	       ntohl(vlocation->vldb.servers[2].s_addr),
-	       vlocation->vldb.srvtmask[2]
-	       );
+	       vl->vldb.name,
+	       vl->vldb.vidmask,
+	       ntohl(vl->vldb.servers[0].s_addr),
+	       vl->vldb.srvtmask[0],
+	       ntohl(vl->vldb.servers[1].s_addr),
+	       vl->vldb.srvtmask[1],
+	       ntohl(vl->vldb.servers[2].s_addr),
+	       vl->vldb.srvtmask[2]);
=20
 	_debug("Vids: %08x %08x %08x",
-	       vlocation->vldb.vid[0],
-	       vlocation->vldb.vid[1],
-	       vlocation->vldb.vid[2]);
+	       vl->vldb.vid[0],
+	       vl->vldb.vid[1],
+	       vl->vldb.vid[2]);
=20
-	if (vlocation->vldb.vidmask & AFS_VOL_VTM_RW) {
-		vid =3D vlocation->vldb.vid[0];
+	if (vl->vldb.vidmask & AFS_VOL_VTM_RW) {
+		vid =3D vl->vldb.vid[0];
 		voltype =3D AFSVL_RWVOL;
-	} else if (vlocation->vldb.vidmask & AFS_VOL_VTM_RO) {
-		vid =3D vlocation->vldb.vid[1];
+	} else if (vl->vldb.vidmask & AFS_VOL_VTM_RO) {
+		vid =3D vl->vldb.vid[1];
 		voltype =3D AFSVL_ROVOL;
-	} else if (vlocation->vldb.vidmask & AFS_VOL_VTM_BAK) {
-		vid =3D vlocation->vldb.vid[2];
+	} else if (vl->vldb.vidmask & AFS_VOL_VTM_BAK) {
+		vid =3D vl->vldb.vid[2];
 		voltype =3D AFSVL_BACKVOL;
 	} else {
 		BUG();
@@ -371,551 +225,482 @@ found_in_cache:
 		voltype =3D 0;
 	}
=20
-	ret =3D afs_vlocation_access_vl_by_id(vlocation, vid, voltype, &vldb)=
;
+	/* contact the server to make sure the volume is still available
+	 * - TODO: need to handle disconnected operation here
+	 */
+	ret =3D afs_vlocation_access_vl_by_id(vl, vid, voltype, vldb);
 	switch (ret) {
 		/* net error */
 	default:
-		printk("kAFS: failed to volume '%*.*s' (%x) up in '%s': %d\n",
-		       namesz, namesz, name, vid, cell->name, ret);
-		goto error;
+		printk(KERN_WARNING "kAFS:"
+		       " failed to update volume '%s' (%x) up in '%s': %d\n",
+		       vl->vldb.name, vid, vl->cell->name, ret);
+		_leave(" =3D %d", ret);
+		return ret;
=20
 		/* pulled from local cache into memory */
 	case 0:
-		goto found_on_vlserver;
+		_leave(" =3D 0");
+		return 0;
=20
 		/* uh oh... looks like the volume got deleted */
 	case -ENOMEDIUM:
-		printk("kAFS: volume '%*.*s' (%x) does not exist '%s'\n",
-		       namesz, namesz, name, vid, cell->name);
+		printk(KERN_ERR "kAFS:"
+		       " volume '%s' (%x) does not exist '%s'\n",
+		       vl->vldb.name, vid, vl->cell->name);
=20
 		/* TODO: make existing record unavailable */
-		goto error;
+		_leave(" =3D %d", ret);
+		return ret;
 	}
+}
=20
-found_on_vlserver:
-	_debug("Done VL Lookup: %*.*s %02x { %08x(%x) %08x(%x) %08x(%x) }",
-	       namesz, namesz, name,
-	       vldb.vidmask,
-	       ntohl(vldb.servers[0].s_addr), vldb.srvtmask[0],
-	       ntohl(vldb.servers[1].s_addr), vldb.srvtmask[1],
-	       ntohl(vldb.servers[2].s_addr), vldb.srvtmask[2]
-	       );
-
-	_debug("Vids: %08x %08x %08x", vldb.vid[0], vldb.vid[1], vldb.vid[2])=
;
+/*
+ * apply the update to a VL record
+ */
+static void afs_vlocation_apply_update(struct afs_vlocation *vl,
+				       struct afs_cache_vlocation *vldb)
+{
+	_debug("Done VL Lookup: %s %02x { %08x(%x) %08x(%x) %08x(%x) }",
+	       vldb->name, vldb->vidmask,
+	       ntohl(vldb->servers[0].s_addr), vldb->srvtmask[0],
+	       ntohl(vldb->servers[1].s_addr), vldb->srvtmask[1],
+	       ntohl(vldb->servers[2].s_addr), vldb->srvtmask[2]);
=20
-	if ((namesz < sizeof(vlocation->vldb.name) &&
-	     vlocation->vldb.name[namesz] !=3D '\0') ||
-	    memcmp(vldb.name, name, namesz) !=3D 0)
-		printk("kAFS: name of volume '%*.*s' changed to '%s' on server\n",
-		       namesz, namesz, name, vldb.name);
+	_debug("Vids: %08x %08x %08x",
+	       vldb->vid[0], vldb->vid[1], vldb->vid[2]);
=20
-	memcpy(&vlocation->vldb, &vldb, sizeof(vlocation->vldb));
+	if (strcmp(vldb->name, vl->vldb.name) !=3D 0)
+		printk(KERN_NOTICE "kAFS:"
+		       " name of volume '%s' changed to '%s' on server\n",
+		       vl->vldb.name, vldb->name);
=20
-	afs_kafstimod_add_timer(&vlocation->upd_timer, 10 * HZ);
+	vl->vldb =3D *vldb;
=20
 #ifdef AFS_CACHING_SUPPORT
 	/* update volume entry in local cache */
-	cachefs_update_cookie(vlocation->cache);
-#endif
-
-	*_vlocation =3D vlocation;
-	_leave(" =3D 0 (%p)",vlocation);
-	return 0;
-
-error:
-	if (vlocation) {
-		if (active) {
-			__afs_put_vlocation(vlocation);
-		} else {
-			list_del(&vlocation->link);
-#ifdef AFS_CACHING_SUPPORT
-			cachefs_relinquish_cookie(vlocation->cache, 0);
+	cachefs_update_cookie(vl->cache);
 #endif
-			afs_put_cell(vlocation->cell);
-			kfree(vlocation);
-		}
-	}
-
-	_leave(" =3D %d", ret);
-	return ret;
 }
=20
 /*
- * finish using a volume location record
- * - caller must have cell->vol_sem write-locked
+ * fill in a volume location record, consulting the cache and the VL s=
erver
+ * both
  */
-static void __afs_put_vlocation(struct afs_vlocation *vlocation)
+static int afs_vlocation_fill_in_record(struct afs_vlocation *vl)
 {
-	struct afs_cell *cell;
+	struct afs_cache_vlocation vldb;
+	int ret;
=20
-	if (!vlocation)
-		return;
+	_enter("");
=20
-	_enter("%s", vlocation->vldb.name);
+	ASSERTCMP(vl->valid, =3D=3D, 0);
=20
-	cell =3D vlocation->cell;
+	memset(&vldb, 0, sizeof(vldb));
=20
-	/* sanity check */
-	BUG_ON(atomic_read(&vlocation->usage) <=3D 0);
+	/* see if we have an in-cache copy (will set vl->valid if there is) *=
/
+#ifdef AFS_CACHING_SUPPORT
+	cachefs_acquire_cookie(cell->cache,
+			       &afs_volume_cache_index_def,
+			       vlocation,
+			       &vl->cache);
+#endif
=20
-	spin_lock(&cell->vl_gylock);
-	if (likely(!atomic_dec_and_test(&vlocation->usage))) {
-		spin_unlock(&cell->vl_gylock);
-		_leave("");
-		return;
+	if (vl->valid) {
+		/* try to update a known volume in the cell VL databases by
+		 * ID as the name may have changed */
+		_debug("found in cache");
+		ret =3D afs_vlocation_update_record(vl, &vldb);
+	} else {
+		/* try to look up an unknown volume in the cell VL databases by
+		 * name */
+		ret =3D afs_vlocation_access_vl_by_name(vl, &vldb);
+		if (ret < 0) {
+			printk("kAFS: failed to locate '%s' in cell '%s'\n",
+			       vl->vldb.name, vl->cell->name);
+			return ret;
+		}
 	}
=20
-	/* move to graveyard queue */
-	list_move_tail(&vlocation->link,&cell->vl_graveyard);
-
-	/* remove from pending timeout queue (refcounted if actually being
-	 * updated) */
-	list_del_init(&vlocation->upd_op.link);
-
-	/* time out in 10 secs */
-	afs_kafstimod_del_timer(&vlocation->upd_timer);
-	afs_kafstimod_add_timer(&vlocation->timeout, 10 * HZ);
-
-	spin_unlock(&cell->vl_gylock);
-
-	_leave(" [killed]");
+	afs_vlocation_apply_update(vl, &vldb);
+	_leave(" =3D 0");
+	return 0;
 }
=20
 /*
- * finish using a volume location record
+ * queue a vlocation record for updates
  */
-void afs_put_vlocation(struct afs_vlocation *vlocation)
+void afs_vlocation_queue_for_updates(struct afs_vlocation *vl)
 {
-	if (vlocation) {
-		struct afs_cell *cell =3D vlocation->cell;
+	struct afs_vlocation *xvl;
=20
-		down_write(&cell->vl_sem);
-		__afs_put_vlocation(vlocation);
-		up_write(&cell->vl_sem);
+	/* wait at least 10 minutes before updating... */
+	vl->update_at =3D get_seconds() + afs_vlocation_update_timeout;
+
+	spin_lock(&afs_vlocation_updates_lock);
+
+	if (!list_empty(&afs_vlocation_updates)) {
+		/* ... but wait at least 1 second more than the newest record
+		 * already queued so that we don't spam the VL server suddenly
+		 * with lots of requests
+		 */
+		xvl =3D list_entry(afs_vlocation_updates.prev,
+				 struct afs_vlocation, update);
+		if (vl->update_at <=3D xvl->update_at)
+			vl->update_at =3D xvl->update_at + 1;
+	} else {
+		queue_delayed_work(afs_vlocation_update_worker,
+				   &afs_vlocation_update,
+				   afs_vlocation_update_timeout * HZ);
 	}
+
+	list_add_tail(&vl->update, &afs_vlocation_updates);
+	spin_unlock(&afs_vlocation_updates_lock);
 }
=20
 /*
- * timeout vlocation record
- * - removes from the cell's graveyard if the usage count is zero
+ * lookup volume location
+ * - iterate through the VL servers in a cell until one of them admits=
 knowing
+ *   about the volume in question
+ * - lookup in the local cache if not able to find on the VL server
+ * - insert/update in the local cache if did get a VL response
  */
-void afs_vlocation_do_timeout(struct afs_vlocation *vlocation)
+struct afs_vlocation *afs_vlocation_lookup(struct afs_cell *cell,
+					   const char *name,
+					   size_t namesz)
 {
-	struct afs_cell *cell;
-
-	_enter("%s", vlocation->vldb.name);
-
-	cell =3D vlocation->cell;
+	struct afs_vlocation *vl;
+	int ret;
=20
-	BUG_ON(atomic_read(&vlocation->usage) < 0);
+	_enter("{%s},%*.*s,%zu",
+	       cell->name, (int) namesz, (int) namesz, name, namesz);
=20
-	/* remove from graveyard if still dead */
-	spin_lock(&cell->vl_gylock);
-	if (atomic_read(&vlocation->usage) =3D=3D 0)
-		list_del_init(&vlocation->link);
-	else
-		vlocation =3D NULL;
-	spin_unlock(&cell->vl_gylock);
+	if (namesz > sizeof(vl->vldb.name)) {
+		_leave(" =3D -ENAMETOOLONG");
+		return ERR_PTR(-ENAMETOOLONG);
+	}
=20
-	if (!vlocation) {
-		_leave("");
-		return; /* resurrected */
+	/* see if we have an in-memory copy first */
+	down_write(&cell->vl_sem);
+	spin_lock(&cell->vl_lock);
+	list_for_each_entry(vl, &cell->vl_list, link) {
+		if (vl->vldb.name[namesz] !=3D '\0')
+			continue;
+		if (memcmp(vl->vldb.name, name, namesz) =3D=3D 0)
+			goto found_in_memory;
 	}
+	spin_unlock(&cell->vl_lock);
=20
-	/* we can now destroy it properly */
-#ifdef AFS_CACHING_SUPPORT
-	cachefs_relinquish_cookie(vlocation->cache, 0);
-#endif
-	afs_put_cell(cell);
+	/* not in the cell's in-memory lists - create a new record */
+	vl =3D afs_vlocation_alloc(cell, name, namesz);
+	if (!vl) {
+		up_write(&cell->vl_sem);
+		return ERR_PTR(-ENOMEM);
+	}
=20
-	kfree(vlocation);
+	afs_get_cell(cell);
=20
-	_leave(" [destroyed]");
-}
+	list_add_tail(&vl->link, &cell->vl_list);
+	vl->state =3D AFS_VL_CREATING;
+	up_write(&cell->vl_sem);
=20
-/*
- * send an update operation to the currently selected server
- */
-static int afs_vlocation_update_begin(struct afs_vlocation *vlocation)
-{
-	afs_voltype_t voltype;
-	afs_volid_t vid;
-	int ret;
+fill_in_record:
+	ret =3D afs_vlocation_fill_in_record(vl);
+	if (ret < 0)
+		goto error_abandon;
+	vl->state =3D AFS_VL_VALID;
+	wake_up(&vl->waitq);
=20
-	_enter("%s{ufs=3D%u ucs=3D%u}",
-	       vlocation->vldb.name,
-	       vlocation->upd_first_svix,
-	       vlocation->upd_curr_svix);
+	/* schedule for regular updates */
+	afs_vlocation_queue_for_updates(vl);
+	goto success;
=20
-	/* try to look up a cached volume in the cell VL databases by ID */
-	if (vlocation->vldb.vidmask & AFS_VOL_VTM_RW) {
-		vid =3D vlocation->vldb.vid[0];
-		voltype =3D AFSVL_RWVOL;
-	} else if (vlocation->vldb.vidmask & AFS_VOL_VTM_RO) {
-		vid =3D vlocation->vldb.vid[1];
-		voltype =3D AFSVL_ROVOL;
-	} else if (vlocation->vldb.vidmask & AFS_VOL_VTM_BAK) {
-		vid =3D vlocation->vldb.vid[2];
-		voltype =3D AFSVL_BACKVOL;
-	} else {
-		BUG();
-		vid =3D 0;
-		voltype =3D 0;
+found_in_memory:
+	/* found in memory */
+	_debug("found in memory");
+	atomic_inc(&vl->usage);
+	spin_unlock(&cell->vl_lock);
+	if (!list_empty(&vl->grave)) {
+		spin_lock(&afs_vlocation_graveyard_lock);
+		list_del_init(&vl->grave);
+		spin_unlock(&afs_vlocation_graveyard_lock);
 	}
+	up_write(&cell->vl_sem);
=20
-	/* contact the chosen server */
-	ret =3D afs_server_lookup(
-		vlocation->cell,
-		&vlocation->cell->vl_addrs[vlocation->upd_curr_svix],
-		&vlocation->upd_op.server);
+	/* see if it was an abandoned record that we might try filling in */
+	while (vl->state !=3D AFS_VL_VALID) {
+		afs_vlocation_state_t state =3D vl->state;
=20
-	switch (ret) {
-	case 0:
-		break;
-	case -ENOMEM:
-	case -ENONET:
-	default:
-		_leave(" =3D %d", ret);
-		return ret;
-	}
+		_debug("invalid [state %d]", state);
=20
-	/* initiate the update operation */
-	ret =3D afs_rxvl_get_entry_by_id_async(&vlocation->upd_op, vid, volty=
pe);
-	if (ret < 0) {
-		_leave(" =3D %d", ret);
-		return ret;
+		if ((state =3D=3D AFS_VL_NEW || state =3D=3D AFS_VL_NO_VOLUME)) {
+			if (cmpxchg(&vl->state, state, AFS_VL_CREATING) =3D=3D
+			    state)
+				goto fill_in_record;
+			continue;
+		}
+
+		/* must now wait for creation or update by someone else to
+		 * complete */
+		_debug("wait");
+
+		ret =3D wait_event_interruptible(
+			vl->waitq,
+			vl->state =3D=3D AFS_VL_NEW ||
+			vl->state =3D=3D AFS_VL_VALID ||
+			vl->state =3D=3D AFS_VL_NO_VOLUME);
+		if (ret < 0)
+			goto error;
 	}
=20
+success:
+	_leave(" =3D %p",vl);
+	return vl;
+
+error_abandon:
+	vl->state =3D AFS_VL_NEW;
+	wake_up(&vl->waitq);
+error:
+	ASSERT(vl !=3D NULL);
+	afs_put_vlocation(vl);
 	_leave(" =3D %d", ret);
-	return ret;
+	return ERR_PTR(ret);
 }
=20
 /*
- * abandon updating a VL record
- * - does not restart the update timer
+ * finish using a volume location record
  */
-static void afs_vlocation_update_abandon(struct afs_vlocation *vlocati=
on,
-					 afs_vlocation_upd_t state,
-					 int ret)
+void afs_put_vlocation(struct afs_vlocation *vl)
 {
-	_enter("%s,%u", vlocation->vldb.name, state);
-
-	if (ret < 0)
-		printk("kAFS: Abandoning VL update '%s': %d\n",
-		       vlocation->vldb.name, ret);
-
-	/* discard the server record */
-	afs_put_server(vlocation->upd_op.server);
-	vlocation->upd_op.server =3D NULL;
+	if (!vl)
+		return;
=20
-	spin_lock(&afs_vlocation_update_lock);
-	afs_vlocation_update =3D NULL;
-	vlocation->upd_state =3D state;
+	_enter("%s", vl->vldb.name);
=20
-	/* TODO: start updating next VL record on pending list */
+	ASSERTCMP(atomic_read(&vl->usage), >, 0);
=20
-	spin_unlock(&afs_vlocation_update_lock);
+	if (likely(!atomic_dec_and_test(&vl->usage))) {
+		_leave("");
+		return;
+	}
=20
-	_leave("");
+	spin_lock(&afs_vlocation_graveyard_lock);
+	if (atomic_read(&vl->usage) =3D=3D 0) {
+		_debug("buried");
+		list_move_tail(&vl->grave, &afs_vlocation_graveyard);
+		vl->time_of_death =3D get_seconds();
+		schedule_delayed_work(&afs_vlocation_reap,
+				      afs_vlocation_timeout * HZ);
+
+		/* suspend updates on this record */
+		if (!list_empty(&vl->update)) {
+			spin_lock(&afs_vlocation_updates_lock);
+			list_del_init(&vl->update);
+			spin_unlock(&afs_vlocation_updates_lock);
+		}
+	}
+	spin_unlock(&afs_vlocation_graveyard_lock);
+	_leave(" [killed?]");
 }
=20
 /*
- * handle periodic update timeouts and busy retry timeouts
- * - called from kafstimod
+ * destroy a dead volume location record
  */
-static void afs_vlocation_update_timer(struct afs_timer *timer)
+static void afs_vlocation_destroy(struct afs_vlocation *vl)
 {
-	struct afs_vlocation *vlocation =3D
-		list_entry(timer, struct afs_vlocation, upd_timer);
-	int ret;
+	_enter("%p", vl);
=20
-	_enter("%s", vlocation->vldb.name);
+#ifdef AFS_CACHING_SUPPORT
+	cachefs_relinquish_cookie(vl->cache, 0);
+#endif
=20
-	/* only update if not in the graveyard (defend against putting too) *=
/
-	spin_lock(&vlocation->cell->vl_gylock);
+	afs_put_cell(vl->cell);
+	kfree(vl);
+}
+
+/*
+ * reap dead volume location records
+ */
+static void afs_vlocation_reaper(struct work_struct *work)
+{
+	LIST_HEAD(corpses);
+	struct afs_vlocation *vl;
+	unsigned long delay, expiry;
+	time_t now;
=20
-	if (!atomic_read(&vlocation->usage))
-		goto out_unlock1;
+	_enter("");
=20
-	spin_lock(&afs_vlocation_update_lock);
+	now =3D get_seconds();
+	spin_lock(&afs_vlocation_graveyard_lock);
+
+	while (!list_empty(&afs_vlocation_graveyard)) {
+		vl =3D list_entry(afs_vlocation_graveyard.next,
+				struct afs_vlocation, grave);
+
+		_debug("check %p", vl);
+
+		/* the queue is ordered most dead first */
+		expiry =3D vl->time_of_death + afs_vlocation_timeout;
+		if (expiry > now) {
+			delay =3D (expiry - now) * HZ;
+			_debug("delay %lu", delay);
+			if (!schedule_delayed_work(&afs_vlocation_reap,
+						   delay)) {
+				cancel_delayed_work(&afs_vlocation_reap);
+				schedule_delayed_work(&afs_vlocation_reap,
+						      delay);
+			}
+			break;
+		}
=20
-	/* if we were woken up due to EBUSY sleep then restart immediately if
-	 * possible or else jump to front of pending queue */
-	if (vlocation->upd_state =3D=3D AFS_VLUPD_BUSYSLEEP) {
-		if (afs_vlocation_update) {
-			list_add(&vlocation->upd_op.link,
-				 &afs_vlocation_update_pendq);
+		spin_lock(&vl->cell->vl_lock);
+		if (atomic_read(&vl->usage) > 0) {
+			_debug("no reap");
+			list_del_init(&vl->grave);
 		} else {
-			afs_get_vlocation(vlocation);
-			afs_vlocation_update =3D vlocation;
-			vlocation->upd_state =3D AFS_VLUPD_INPROGRESS;
+			_debug("reap");
+			list_move_tail(&vl->grave, &corpses);
+			list_del_init(&vl->link);
 		}
-		goto out_unlock2;
+		spin_unlock(&vl->cell->vl_lock);
 	}
=20
-	/* put on pending queue if there's already another update in progress=
 */
-	if (afs_vlocation_update) {
-		vlocation->upd_state =3D AFS_VLUPD_PENDING;
-		list_add_tail(&vlocation->upd_op.link,
-			      &afs_vlocation_update_pendq);
-		goto out_unlock2;
-	}
+	spin_unlock(&afs_vlocation_graveyard_lock);
=20
-	/* hold a ref on it while actually updating */
-	afs_get_vlocation(vlocation);
-	afs_vlocation_update =3D vlocation;
-	vlocation->upd_state =3D AFS_VLUPD_INPROGRESS;
-
-	spin_unlock(&afs_vlocation_update_lock);
-	spin_unlock(&vlocation->cell->vl_gylock);
-
-	/* okay... we can start the update */
-	_debug("BEGIN VL UPDATE [%s]", vlocation->vldb.name);
-	vlocation->upd_first_svix =3D vlocation->cell->vl_curr_svix;
-	vlocation->upd_curr_svix =3D vlocation->upd_first_svix;
-	vlocation->upd_rej_cnt =3D 0;
-	vlocation->upd_busy_cnt =3D 0;
-
-	ret =3D afs_vlocation_update_begin(vlocation);
-	if (ret < 0) {
-		afs_vlocation_update_abandon(vlocation, AFS_VLUPD_SLEEP, ret);
-		afs_kafstimod_add_timer(&vlocation->upd_timer,
-					AFS_VLDB_TIMEOUT);
-		afs_put_vlocation(vlocation);
+	/* now reap the corpses we've extracted */
+	while (!list_empty(&corpses)) {
+		vl =3D list_entry(corpses.next, struct afs_vlocation, grave);
+		list_del(&vl->grave);
+		afs_vlocation_destroy(vl);
 	}
=20
 	_leave("");
-	return;
+}
=20
-out_unlock2:
-	spin_unlock(&afs_vlocation_update_lock);
-out_unlock1:
-	spin_unlock(&vlocation->cell->vl_gylock);
-	_leave("");
+/*
+ * initialise the VL update process
+ */
+int __init afs_vlocation_update_init(void)
+{
+	afs_vlocation_update_worker =3D
+		create_singlethread_workqueue("kafs_vlupdated");
+	return afs_vlocation_update_worker ? 0 : -ENOMEM;
+}
+
+/*
+ * discard all the volume location records for rmmod
+ */
+void __exit afs_vlocation_purge(void)
+{
+	afs_vlocation_timeout =3D 0;
+
+	spin_lock(&afs_vlocation_updates_lock);
+	list_del_init(&afs_vlocation_updates);
+	spin_unlock(&afs_vlocation_updates_lock);
+	cancel_delayed_work(&afs_vlocation_update);
+	queue_delayed_work(afs_vlocation_update_worker,
+			   &afs_vlocation_update, 0);
+	destroy_workqueue(afs_vlocation_update_worker);
+
+	cancel_delayed_work(&afs_vlocation_reap);
+	schedule_delayed_work(&afs_vlocation_reap, 0);
 }
=20
 /*
- * attend to an update operation upon which an event happened
- * - called in kafsasyncd context
+ * update a volume location
  */
-static void afs_vlocation_update_attend(struct afs_async_op *op)
+static void afs_vlocation_updater(struct work_struct *work)
 {
 	struct afs_cache_vlocation vldb;
-	struct afs_vlocation *vlocation =3D
-		list_entry(op, struct afs_vlocation, upd_op);
-	unsigned tmp;
+	struct afs_vlocation *vl, *xvl;
+	time_t now;
+	long timeout;
 	int ret;
=20
-	_enter("%s", vlocation->vldb.name);
-
-	ret =3D afs_rxvl_get_entry_by_id_async2(op, &vldb);
-	switch (ret) {
-	case -EAGAIN:
-		_leave(" [unfinished]");
-		return;
-
-	case 0:
-		_debug("END VL UPDATE: %d\n", ret);
-		vlocation->valid =3D 1;
-
-		_debug("Done VL Lookup: %02x { %08x(%x) %08x(%x) %08x(%x) }",
-		       vldb.vidmask,
-		       ntohl(vldb.servers[0].s_addr), vldb.srvtmask[0],
-		       ntohl(vldb.servers[1].s_addr), vldb.srvtmask[1],
-		       ntohl(vldb.servers[2].s_addr), vldb.srvtmask[2]
-		       );
-
-		_debug("Vids: %08x %08x %08x",
-		       vldb.vid[0], vldb.vid[1], vldb.vid[2]);
-
-		afs_vlocation_update_abandon(vlocation, AFS_VLUPD_SLEEP, 0);
-
-		down_write(&vlocation->cell->vl_sem);
-
-		/* actually update the cache */
-		if (strncmp(vldb.name, vlocation->vldb.name,
-			    sizeof(vlocation->vldb.name)) !=3D 0)
-			printk("kAFS: name of volume '%s'"
-			       " changed to '%s' on server\n",
-			       vlocation->vldb.name, vldb.name);
-
-		memcpy(&vlocation->vldb, &vldb, sizeof(vlocation->vldb));
-
-#if 0
-		/* TODO update volume entry in local cache */
-#endif
-
-		up_write(&vlocation->cell->vl_sem);
-
-		if (ret < 0)
-			printk("kAFS: failed to update local cache: %d\n", ret);
-
-		afs_kafstimod_add_timer(&vlocation->upd_timer,
-					AFS_VLDB_TIMEOUT);
-		afs_put_vlocation(vlocation);
-		_leave(" [found]");
-		return;
-
-	case -ENOMEDIUM:
-		vlocation->upd_rej_cnt++;
-		goto try_next;
-
-		/* the server is locked - retry in a very short while */
-	case -EBUSY:
-		vlocation->upd_busy_cnt++;
-		if (vlocation->upd_busy_cnt > 3)
-			goto try_next; /* too many retries */
-
-		afs_vlocation_update_abandon(vlocation,
-					     AFS_VLUPD_BUSYSLEEP, 0);
-		afs_kafstimod_add_timer(&vlocation->upd_timer, HZ / 2);
-		afs_put_vlocation(vlocation);
-		_leave(" [busy]");
-		return;
-
-	case -ENETUNREACH:
-	case -EHOSTUNREACH:
-	case -ECONNREFUSED:
-	case -EREMOTEIO:
-		/* record bad vlserver info in the cell too
-		 * - TODO: use down_write_trylock() if available
-		 */
-		if (vlocation->upd_curr_svix =3D=3D vlocation->cell->vl_curr_svix)
-			vlocation->cell->vl_curr_svix =3D
-				vlocation->cell->vl_curr_svix %
-				vlocation->cell->vl_naddrs;
-
-	case -EBADRQC:
-	case -EINVAL:
-	case -EACCES:
-	case -EBADMSG:
-		goto try_next;
-
-	default:
-		goto abandon;
-	}
-
-	/* try contacting the next server */
-try_next:
-	vlocation->upd_busy_cnt =3D 0;
-
-	/* discard the server record */
-	afs_put_server(vlocation->upd_op.server);
-	vlocation->upd_op.server =3D NULL;
+	_enter("");
=20
-	tmp =3D vlocation->cell->vl_naddrs;
-	if (tmp =3D=3D 0)
-		goto abandon;
+	now =3D get_seconds();
=20
-	vlocation->upd_curr_svix++;
-	if (vlocation->upd_curr_svix >=3D tmp)
-		vlocation->upd_curr_svix =3D 0;
-	if (vlocation->upd_first_svix >=3D tmp)
-		vlocation->upd_first_svix =3D tmp - 1;
+	/* find a record to update */
+	spin_lock(&afs_vlocation_updates_lock);
+	for (;;) {
+		if (list_empty(&afs_vlocation_updates)) {
+			spin_unlock(&afs_vlocation_updates_lock);
+			_leave(" [nothing]");
+			return;
+		}
=20
-	/* move to the next server */
-	if (vlocation->upd_curr_svix !=3D vlocation->upd_first_svix) {
-		afs_vlocation_update_begin(vlocation);
-		_leave(" [next]");
-		return;
+		vl =3D list_entry(afs_vlocation_updates.next,
+				struct afs_vlocation, update);
+		if (atomic_read(&vl->usage) > 0)
+			break;
+		list_del_init(&vl->update);
 	}
=20
-	/* run out of servers to try - was the volume rejected? */
-	if (vlocation->upd_rej_cnt > 0) {
-		printk("kAFS: Active volume no longer valid '%s'\n",
-		       vlocation->vldb.name);
-		vlocation->valid =3D 0;
-		afs_vlocation_update_abandon(vlocation, AFS_VLUPD_SLEEP, 0);
-		afs_kafstimod_add_timer(&vlocation->upd_timer,
-					AFS_VLDB_TIMEOUT);
-		afs_put_vlocation(vlocation);
-		_leave(" [invalidated]");
+	timeout =3D vl->update_at - now;
+	if (timeout > 0) {
+		queue_delayed_work(afs_vlocation_update_worker,
+				   &afs_vlocation_update, timeout * HZ);
+		spin_unlock(&afs_vlocation_updates_lock);
+		_leave(" [nothing]");
 		return;
 	}
=20
-	/* abandon the update */
-abandon:
-	afs_vlocation_update_abandon(vlocation, AFS_VLUPD_SLEEP, ret);
-	afs_kafstimod_add_timer(&vlocation->upd_timer, HZ * 10);
-	afs_put_vlocation(vlocation);
-	_leave(" [abandoned]");
-}
+	list_del_init(&vl->update);
+	atomic_inc(&vl->usage);
+	spin_unlock(&afs_vlocation_updates_lock);
=20
-/*
- * deal with an update operation being discarded
- * - called in kafsasyncd context when it's dying due to rmmod
- * - the call has already been aborted and put()'d
- */
-static void afs_vlocation_update_discard(struct afs_async_op *op)
-{
-	struct afs_vlocation *vlocation =3D
-		list_entry(op, struct afs_vlocation, upd_op);
-
-	_enter("%s", vlocation->vldb.name);
+	/* we can now perform the update */
+	_debug("update %s", vl->vldb.name);
+	vl->state =3D AFS_VL_UPDATING;
+	vl->upd_rej_cnt =3D 0;
+	vl->upd_busy_cnt =3D 0;
=20
-	afs_put_server(op->server);
-	op->server =3D NULL;
-
-	afs_put_vlocation(vlocation);
+	ret =3D afs_vlocation_update_record(vl, &vldb);
+	switch (ret) {
+	case 0:
+		afs_vlocation_apply_update(vl, &vldb);
+		vl->state =3D AFS_VL_VALID;
+		break;
+	case -ENOMEDIUM:
+		vl->state =3D AFS_VL_VOLUME_DELETED;
+		break;
+	default:
+		vl->state =3D AFS_VL_UNCERTAIN;
+		break;
+	}
=20
-	_leave("");
-}
+	/* and then reschedule */
+	_debug("reschedule");
+	vl->update_at =3D get_seconds() + afs_vlocation_update_timeout;
=20
-/*
- * match a VLDB record stored in the cache
- * - may also load target from entry
- */
-#ifdef AFS_CACHING_SUPPORT
-static cachefs_match_val_t afs_vlocation_cache_match(void *target,
-						     const void *entry)
-{
-	const struct afs_cache_vlocation *vldb =3D entry;
-	struct afs_vlocation *vlocation =3D target;
-
-	_enter("{%s},{%s}", vlocation->vldb.name, vldb->name);
-
-	if (strncmp(vlocation->vldb.name, vldb->name, sizeof(vldb->name)) =3D=
=3D 0
-	    ) {
-		if (!vlocation->valid ||
-		    vlocation->vldb.rtime =3D=3D vldb->rtime
-		    ) {
-			vlocation->vldb =3D *vldb;
-			vlocation->valid =3D 1;
-			_leave(" =3D SUCCESS [c->m]");
-			return CACHEFS_MATCH_SUCCESS;
-		} else if (memcmp(&vlocation->vldb, vldb, sizeof(*vldb)) !=3D 0) {
-			/* delete if VIDs for this name differ */
-			if (memcmp(&vlocation->vldb.vid,
-				   &vldb->vid,
-				   sizeof(vldb->vid)) !=3D 0) {
-				_leave(" =3D DELETE");
-				return CACHEFS_MATCH_SUCCESS_DELETE;
-			}
+	spin_lock(&afs_vlocation_updates_lock);
=20
-			_leave(" =3D UPDATE");
-			return CACHEFS_MATCH_SUCCESS_UPDATE;
-		} else {
-			_leave(" =3D SUCCESS");
-			return CACHEFS_MATCH_SUCCESS;
-		}
+	if (!list_empty(&afs_vlocation_updates)) {
+		/* next update in 10 minutes, but wait at least 1 second more
+		 * than the newest record already queued so that we don't spam
+		 * the VL server suddenly with lots of requests
+		 */
+		xvl =3D list_entry(afs_vlocation_updates.prev,
+				 struct afs_vlocation, update);
+		if (vl->update_at <=3D xvl->update_at)
+			vl->update_at =3D xvl->update_at + 1;
+		xvl =3D list_entry(afs_vlocation_updates.next,
+				 struct afs_vlocation, update);
+		timeout =3D xvl->update_at - now;
+		if (timeout < 0)
+			timeout =3D 0;
+	} else {
+		timeout =3D afs_vlocation_update_timeout;
 	}
=20
-	_leave(" =3D FAILED");
-	return CACHEFS_MATCH_FAILED;
-}
-#endif
+	ASSERT(list_empty(&vl->update));
=20
-/*
- * update a VLDB record stored in the cache
- */
-#ifdef AFS_CACHING_SUPPORT
-static void afs_vlocation_cache_update(void *source, void *entry)
-{
-	struct afs_cache_vlocation *vldb =3D entry;
-	struct afs_vlocation *vlocation =3D source;
-
-	_enter("");
+	list_add_tail(&vl->update, &afs_vlocation_updates);
=20
-	*vldb =3D vlocation->vldb;
+	_debug("timeout %ld", timeout);
+	queue_delayed_work(afs_vlocation_update_worker,
+			   &afs_vlocation_update, timeout * HZ);
+	spin_unlock(&afs_vlocation_updates_lock);
+	afs_put_vlocation(vl);
 }
-#endif
diff --git a/fs/afs/vnode.c b/fs/afs/vnode.c
index 4ab1ed7..d2ca139 100644
--- a/fs/afs/vnode.c
+++ b/fs/afs/vnode.c
@@ -1,6 +1,6 @@
 /* AFS vnode management
  *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2002, 2007 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -14,72 +14,183 @@
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/fs.h>
-#include <linux/pagemap.h>
-#include "volume.h"
-#include "cell.h"
-#include "cmservice.h"
-#include "fsclient.h"
-#include "vlclient.h"
-#include "vnode.h"
 #include "internal.h"
=20
-static void afs_vnode_cb_timed_out(struct afs_timer *timer);
+#if 0
+static noinline bool dump_tree_aux(struct rb_node *node, struct rb_nod=
e *parent,
+				   int depth, char lr)
+{
+	struct afs_vnode *vnode;
+	bool bad =3D false;
+
+	if (!node)
+		return false;
+
+	if (node->rb_left)
+		bad =3D dump_tree_aux(node->rb_left, node, depth + 2, '/');
+
+	vnode =3D rb_entry(node, struct afs_vnode, cb_promise);
+	kdebug("%c %*.*s%c%p {%d}",
+	       rb_is_red(node) ? 'R' : 'B',
+	       depth, depth, "", lr,
+	       vnode, vnode->cb_expires_at);
+	if (rb_parent(node) !=3D parent) {
+		printk("BAD: %p !=3D %p\n", rb_parent(node), parent);
+		bad =3D true;
+	}
=20
-struct afs_timer_ops afs_vnode_cb_timed_out_ops =3D {
-	.timed_out	=3D afs_vnode_cb_timed_out,
-};
+	if (node->rb_right)
+		bad |=3D dump_tree_aux(node->rb_right, node, depth + 2, '\\');
=20
-#ifdef AFS_CACHING_SUPPORT
-static cachefs_match_val_t afs_vnode_cache_match(void *target,
-						 const void *entry);
-static void afs_vnode_cache_update(void *source, void *entry);
+	return bad;
+}
=20
-struct cachefs_index_def afs_vnode_cache_index_def =3D {
-	.name		=3D "vnode",
-	.data_size	=3D sizeof(struct afs_cache_vnode),
-	.keys[0]	=3D { CACHEFS_INDEX_KEYS_BIN, 4 },
-	.match		=3D afs_vnode_cache_match,
-	.update		=3D afs_vnode_cache_update,
-};
+static noinline void dump_tree(const char *name, struct afs_server *se=
rver)
+{
+	kenter("%s", name);
+	if (dump_tree_aux(server->cb_promises.rb_node, NULL, 0, '-'))
+		BUG();
+}
 #endif
=20
 /*
- * handle a callback timing out
- * TODO: retain a ref to vnode struct for an outstanding callback time=
out
+ * insert a vnode into the backing server's vnode tree
  */
-static void afs_vnode_cb_timed_out(struct afs_timer *timer)
+static void afs_install_vnode(struct afs_vnode *vnode,
+			      struct afs_server *server)
 {
-	struct afs_server *oldserver;
-	struct afs_vnode *vnode;
+	struct afs_server *old_server =3D vnode->server;
+	struct afs_vnode *xvnode;
+	struct rb_node *parent, **p;
=20
-	vnode =3D list_entry(timer, struct afs_vnode, cb_timeout);
+	_enter("%p,%p", vnode, server);
=20
-	_enter("%p", vnode);
+	if (old_server) {
+		spin_lock(&old_server->fs_lock);
+		rb_erase(&vnode->server_rb, &old_server->fs_vnodes);
+		spin_unlock(&old_server->fs_lock);
+	}
=20
-	/* set the changed flag in the vnode and release the server */
-	spin_lock(&vnode->lock);
+	afs_get_server(server);
+	vnode->server =3D server;
+	afs_put_server(old_server);
+
+	/* insert into the server's vnode tree in FID order */
+	spin_lock(&server->fs_lock);
+
+	parent =3D NULL;
+	p =3D &server->fs_vnodes.rb_node;
+	while (*p) {
+		parent =3D *p;
+		xvnode =3D rb_entry(parent, struct afs_vnode, server_rb);
+		if (vnode->fid.vid < xvnode->fid.vid)
+			p =3D &(*p)->rb_left;
+		else if (vnode->fid.vid > xvnode->fid.vid)
+			p =3D &(*p)->rb_right;
+		else if (vnode->fid.vnode < xvnode->fid.vnode)
+			p =3D &(*p)->rb_left;
+		else if (vnode->fid.vnode > xvnode->fid.vnode)
+			p =3D &(*p)->rb_right;
+		else if (vnode->fid.unique < xvnode->fid.unique)
+			p =3D &(*p)->rb_left;
+		else if (vnode->fid.unique > xvnode->fid.unique)
+			p =3D &(*p)->rb_right;
+		else
+			BUG(); /* can't happen unless afs_iget() malfunctions */
+	}
=20
-	oldserver =3D xchg(&vnode->cb_server, NULL);
-	if (oldserver) {
-		vnode->flags |=3D AFS_VNODE_CHANGED;
+	rb_link_node(&vnode->server_rb, parent, p);
+	rb_insert_color(&vnode->server_rb, &server->fs_vnodes);
=20
-		spin_lock(&afs_cb_hash_lock);
-		list_del_init(&vnode->cb_hash_link);
-		spin_unlock(&afs_cb_hash_lock);
+	spin_unlock(&server->fs_lock);
+	_leave("");
+}
=20
-		spin_lock(&oldserver->cb_lock);
-		list_del_init(&vnode->cb_link);
-		spin_unlock(&oldserver->cb_lock);
+/*
+ * insert a vnode into the promising server's update/expiration tree
+ * - caller must hold vnode->lock
+ */
+static void afs_vnode_note_promise(struct afs_vnode *vnode,
+				   struct afs_server *server)
+{
+	struct afs_server *old_server;
+	struct afs_vnode *xvnode;
+	struct rb_node *parent, **p;
+
+	_enter("%p,%p", vnode, server);
+
+	ASSERT(server !=3D NULL);
+
+	old_server =3D vnode->server;
+	if (vnode->cb_promised) {
+		if (server =3D=3D old_server &&
+		    vnode->cb_expires =3D=3D vnode->cb_expires_at) {
+			_leave(" [no change]");
+			return;
+		}
+
+		spin_lock(&old_server->cb_lock);
+		if (vnode->cb_promised) {
+			_debug("delete");
+			rb_erase(&vnode->cb_promise, &old_server->cb_promises);
+			vnode->cb_promised =3D false;
+		}
+		spin_unlock(&old_server->cb_lock);
 	}
=20
-	spin_unlock(&vnode->lock);
+	if (vnode->server !=3D server)
+		afs_install_vnode(vnode, server);
+
+	vnode->cb_expires_at =3D vnode->cb_expires;
+	_debug("PROMISE on %p {%lu}",
+	       vnode, (unsigned long) vnode->cb_expires_at);
+
+	/* abuse an RB-tree to hold the expiration order (we may have multipl=
e
+	 * items with the same expiration time) */
+	spin_lock(&server->cb_lock);
+
+	parent =3D NULL;
+	p =3D &server->cb_promises.rb_node;
+	while (*p) {
+		parent =3D *p;
+		xvnode =3D rb_entry(parent, struct afs_vnode, cb_promise);
+		if (vnode->cb_expires_at < xvnode->cb_expires_at)
+			p =3D &(*p)->rb_left;
+		else
+			p =3D &(*p)->rb_right;
+	}
=20
-	afs_put_server(oldserver);
+	rb_link_node(&vnode->cb_promise, parent, p);
+	rb_insert_color(&vnode->cb_promise, &server->cb_promises);
+	vnode->cb_promised =3D true;
=20
+	spin_unlock(&server->cb_lock);
 	_leave("");
 }
=20
 /*
+ * handle remote file deletion by discarding the callback promise
+ */
+static void afs_vnode_deleted_remotely(struct afs_vnode *vnode)
+{
+	struct afs_server *server;
+
+	set_bit(AFS_VNODE_DELETED, &vnode->flags);
+
+	server =3D vnode->server;
+	if (vnode->cb_promised) {
+		spin_lock(&server->cb_lock);
+		if (vnode->cb_promised) {
+			rb_erase(&vnode->cb_promise, &server->cb_promises);
+			vnode->cb_promised =3D false;
+		}
+		spin_unlock(&server->cb_lock);
+	}
+
+	afs_put_server(server);
+}
+
+/*
  * finish off updating the recorded status of a file
  * - starts callback expiry timer
  * - adds to server's callback list
@@ -94,43 +205,19 @@ static void afs_vnode_finalise_status_update(struc=
t afs_vnode *vnode,
=20
 	spin_lock(&vnode->lock);
=20
-	vnode->flags &=3D ~AFS_VNODE_CHANGED;
-
-	if (ret =3D=3D 0) {
-		/* adjust the callback timeout appropriately */
-		afs_kafstimod_add_timer(&vnode->cb_timeout,
-					vnode->cb_expiry * HZ);
-
-		spin_lock(&afs_cb_hash_lock);
-		list_move_tail(&vnode->cb_hash_link,
-			       &afs_cb_hash(server, &vnode->fid));
-		spin_unlock(&afs_cb_hash_lock);
-
-		/* swap ref to old callback server with that for new callback
-		 * server */
-		oldserver =3D xchg(&vnode->cb_server, server);
-		if (oldserver !=3D server) {
-			if (oldserver) {
-				spin_lock(&oldserver->cb_lock);
-				list_del_init(&vnode->cb_link);
-				spin_unlock(&oldserver->cb_lock);
-			}
-
-			afs_get_server(server);
-			spin_lock(&server->cb_lock);
-			list_add_tail(&vnode->cb_link, &server->cb_promises);
-			spin_unlock(&server->cb_lock);
-		} else {
-			/* same server */
-			oldserver =3D NULL;
-		}
-	} else if (ret =3D=3D -ENOENT) {
-		/* the file was deleted - clear the callback timeout */
-		oldserver =3D xchg(&vnode->cb_server, NULL);
-		afs_kafstimod_del_timer(&vnode->cb_timeout);
+	clear_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
=20
+	switch (ret) {
+	case 0:
+		afs_vnode_note_promise(vnode, server);
+		break;
+	case -ENOENT:
+		/* the file was deleted on the server */
 		_debug("got NOENT from server - marking file deleted");
-		vnode->flags |=3D AFS_VNODE_DELETED;
+		afs_vnode_deleted_remotely(vnode);
+		break;
+	default:
+		break;
 	}
=20
 	vnode->update_cnt--;
@@ -162,19 +249,21 @@ int afs_vnode_fetch_status(struct afs_vnode *vnod=
e)
 	       vnode->volume->vlocation->vldb.name,
 	       vnode->fid.vid, vnode->fid.vnode, vnode->fid.unique);
=20
-	if (!(vnode->flags & AFS_VNODE_CHANGED) && vnode->cb_server) {
+	if (!test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags) &&
+	    vnode->cb_promised) {
 		_leave(" [unchanged]");
 		return 0;
 	}
=20
-	if (vnode->flags & AFS_VNODE_DELETED) {
+	if (test_bit(AFS_VNODE_DELETED, &vnode->flags)) {
 		_leave(" [deleted]");
 		return -ENOENT;
 	}
=20
 	spin_lock(&vnode->lock);
=20
-	if (!(vnode->flags & AFS_VNODE_CHANGED)) {
+	if (!test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags) &&
+	    vnode->cb_promised) {
 		spin_unlock(&vnode->lock);
 		_leave(" [unchanged]");
 		return 0;
@@ -183,17 +272,18 @@ int afs_vnode_fetch_status(struct afs_vnode *vnod=
e)
 	if (vnode->update_cnt > 0) {
 		/* someone else started a fetch */
 		set_current_state(TASK_UNINTERRUPTIBLE);
+		ASSERT(myself.func !=3D NULL);
 		add_wait_queue(&vnode->update_waitq, &myself);
=20
 		/* wait for the status to be updated */
 		for (;;) {
-			if (!(vnode->flags & AFS_VNODE_CHANGED))
+			if (!test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags))
 				break;
-			if (vnode->flags & AFS_VNODE_DELETED)
+			if (test_bit(AFS_VNODE_DELETED, &vnode->flags))
 				break;
=20
-			/* it got updated and invalidated all before we saw
-			 * it */
+			/* check to see if it got updated and invalidated all
+			 * before we saw it */
 			if (vnode->update_cnt =3D=3D 0) {
 				remove_wait_queue(&vnode->update_waitq,
 						  &myself);
@@ -213,7 +303,8 @@ int afs_vnode_fetch_status(struct afs_vnode *vnode)
 		spin_unlock(&vnode->lock);
 		set_current_state(TASK_RUNNING);
=20
-		return vnode->flags & AFS_VNODE_DELETED ? -ENOENT : 0;
+		return test_bit(AFS_VNODE_DELETED, &vnode->flags) ?
+			-ENOENT : 0;
 	}
=20
 get_anyway:
@@ -226,15 +317,17 @@ get_anyway:
 	 * vnode */
 	do {
 		/* pick a server to query */
-		ret =3D afs_volume_pick_fileserver(vnode->volume, &server);
-		if (ret<0)
-			return ret;
+		server =3D afs_volume_pick_fileserver(vnode);
+		if (IS_ERR(server))
+			return PTR_ERR(server);
=20
-		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
+		_debug("USING SERVER: %p{%08x}",
+		       server, ntohl(server->addr.s_addr));
=20
-		ret =3D afs_rxfs_fetch_file_status(server, vnode, NULL);
+		ret =3D afs_fs_fetch_file_status(server, vnode, NULL,
+					       &afs_sync_call);
=20
-	} while (!afs_volume_release_fileserver(vnode->volume, server, ret));
+	} while (!afs_volume_release_fileserver(vnode, server, ret));
=20
 	/* adjust the flags */
 	afs_vnode_finalise_status_update(vnode, server, ret);
@@ -247,8 +340,8 @@ get_anyway:
  * fetch file data from the volume
  * - TODO implement caching and server failover
  */
-int afs_vnode_fetch_data(struct afs_vnode *vnode,
-			 struct afs_rxfs_fetch_descriptor *desc)
+int afs_vnode_fetch_data(struct afs_vnode *vnode, off_t offset, size_t=
 length,
+			 struct page *page)
 {
 	struct afs_server *server;
 	int ret;
@@ -268,15 +361,16 @@ int afs_vnode_fetch_data(struct afs_vnode *vnode,
 	 * vnode */
 	do {
 		/* pick a server to query */
-		ret =3D afs_volume_pick_fileserver(vnode->volume, &server);
-		if (ret < 0)
-			return ret;
+		server =3D afs_volume_pick_fileserver(vnode);
+		if (IS_ERR(server))
+			return PTR_ERR(server);
=20
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
=20
-		ret =3D afs_rxfs_fetch_file_data(server, vnode, desc, NULL);
+		ret =3D afs_fs_fetch_data(server, vnode, offset, length, page,
+					NULL, &afs_sync_call);
=20
-	} while (!afs_volume_release_fileserver(vnode->volume, server, ret));
+	} while (!afs_volume_release_fileserver(vnode, server, ret));
=20
 	/* adjust the flags */
 	afs_vnode_finalise_status_update(vnode, server, ret);
@@ -284,99 +378,3 @@ int afs_vnode_fetch_data(struct afs_vnode *vnode,
 	_leave(" =3D %d", ret);
 	return ret;
 }
-
-/*
- * break any outstanding callback on a vnode
- * - only relevent to server that issued it
- */
-int afs_vnode_give_up_callback(struct afs_vnode *vnode)
-{
-	struct afs_server *server;
-	int ret;
-
-	_enter("%s,{%u,%u,%u}",
-	       vnode->volume->vlocation->vldb.name,
-	       vnode->fid.vid,
-	       vnode->fid.vnode,
-	       vnode->fid.unique);
-
-	spin_lock(&afs_cb_hash_lock);
-	list_del_init(&vnode->cb_hash_link);
-	spin_unlock(&afs_cb_hash_lock);
-
-	/* set the changed flag in the vnode and release the server */
-	spin_lock(&vnode->lock);
-
-	afs_kafstimod_del_timer(&vnode->cb_timeout);
-
-	server =3D xchg(&vnode->cb_server, NULL);
-	if (server) {
-		vnode->flags |=3D AFS_VNODE_CHANGED;
-
-		spin_lock(&server->cb_lock);
-		list_del_init(&vnode->cb_link);
-		spin_unlock(&server->cb_lock);
-	}
-
-	spin_unlock(&vnode->lock);
-
-	ret =3D 0;
-	if (server) {
-		ret =3D afs_rxfs_give_up_callback(server, vnode);
-		afs_put_server(server);
-	}
-
-	_leave(" =3D %d", ret);
-	return ret;
-}
-
-/*
- * match a vnode record stored in the cache
- */
-#ifdef AFS_CACHING_SUPPORT
-static cachefs_match_val_t afs_vnode_cache_match(void *target,
-						 const void *entry)
-{
-	const struct afs_cache_vnode *cvnode =3D entry;
-	struct afs_vnode *vnode =3D target;
-
-	_enter("{%x,%x,%Lx},{%x,%x,%Lx}",
-	       vnode->fid.vnode,
-	       vnode->fid.unique,
-	       vnode->status.version,
-	       cvnode->vnode_id,
-	       cvnode->vnode_unique,
-	       cvnode->data_version);
-
-	if (vnode->fid.vnode !=3D cvnode->vnode_id) {
-		_leave(" =3D FAILED");
-		return CACHEFS_MATCH_FAILED;
-	}
-
-	if (vnode->fid.unique !=3D cvnode->vnode_unique ||
-	    vnode->status.version !=3D cvnode->data_version) {
-		_leave(" =3D DELETE");
-		return CACHEFS_MATCH_SUCCESS_DELETE;
-	}
-
-	_leave(" =3D SUCCESS");
-	return CACHEFS_MATCH_SUCCESS;
-}
-#endif
-
-/*
- * update a vnode record stored in the cache
- */
-#ifdef AFS_CACHING_SUPPORT
-static void afs_vnode_cache_update(void *source, void *entry)
-{
-	struct afs_cache_vnode *cvnode =3D entry;
-	struct afs_vnode *vnode =3D source;
-
-	_enter("");
-
-	cvnode->vnode_id	=3D vnode->fid.vnode;
-	cvnode->vnode_unique	=3D vnode->fid.unique;
-	cvnode->data_version	=3D vnode->status.version;
-}
-#endif
diff --git a/fs/afs/vnode.h b/fs/afs/vnode.h
deleted file mode 100644
index 7f6d05b..0000000
--- a/fs/afs/vnode.h
+++ /dev/null
@@ -1,84 +0,0 @@
-/* AFS vnode record
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef AFS_VNODE_H
-#define AFS_VNODE_H
-
-#include <linux/fs.h>
-#include "server.h"
-#include "kafstimod.h"
-#include "cache.h"
-
-struct afs_rxfs_fetch_descriptor;
-
-extern struct afs_timer_ops afs_vnode_cb_timed_out_ops;
-
-/*
- * vnode catalogue entry
- */
-struct afs_cache_vnode {
-	afs_vnodeid_t		vnode_id;	/* vnode ID */
-	unsigned		vnode_unique;	/* vnode ID uniquifier */
-	afs_dataversion_t	data_version;	/* data version */
-};
-
-#ifdef AFS_CACHING_SUPPORT
-extern struct cachefs_index_def afs_vnode_cache_index_def;
-#endif
-
-/*
- * AFS inode private data
- */
-struct afs_vnode {
-	struct inode		vfs_inode;	/* the VFS's inode record */
-
-	struct afs_volume	*volume;	/* volume on which vnode resides */
-	struct afs_fid		fid;		/* the file identifier for this inode */
-	struct afs_file_status	status;		/* AFS status info for this file */
-#ifdef AFS_CACHING_SUPPORT
-	struct cachefs_cookie	*cache;		/* caching cookie */
-#endif
-
-	wait_queue_head_t	update_waitq;	/* status fetch waitqueue */
-	unsigned		update_cnt;	/* number of outstanding ops that will update t=
he
-						 * status */
-	spinlock_t		lock;		/* waitqueue/flags lock */
-	unsigned		flags;
-#define AFS_VNODE_CHANGED	0x00000001	/* set if vnode reported changed =
by callback */
-#define AFS_VNODE_DELETED	0x00000002	/* set if vnode deleted on server=
 */
-#define AFS_VNODE_MOUNTPOINT	0x00000004	/* set if vnode is a mountpoin=
t symlink */
-
-	/* outstanding callback notification on this file */
-	struct afs_server	*cb_server;	/* server that made the current promise=
 */
-	struct list_head	cb_link;	/* link in server's promises list */
-	struct list_head	cb_hash_link;	/* link in master callback hash */
-	struct afs_timer	cb_timeout;	/* timeout on promise */
-	unsigned		cb_version;	/* callback version */
-	unsigned		cb_expiry;	/* callback expiry time */
-	afs_callback_type_t	cb_type;	/* type of callback */
-};
-
-static inline struct afs_vnode *AFS_FS_I(struct inode *inode)
-{
-	return container_of(inode, struct afs_vnode, vfs_inode);
-}
-
-static inline struct inode *AFS_VNODE_TO_I(struct afs_vnode *vnode)
-{
-	return &vnode->vfs_inode;
-}
-
-extern int afs_vnode_fetch_status(struct afs_vnode *);
-extern int afs_vnode_fetch_data(struct afs_vnode *,
-				struct afs_rxfs_fetch_descriptor *);
-extern int afs_vnode_give_up_callback(struct afs_vnode *);
-
-#endif /* AFS_VNODE_H */
diff --git a/fs/afs/volume.c b/fs/afs/volume.c
index c82e1bb..45491cf 100644
--- a/fs/afs/volume.c
+++ b/fs/afs/volume.c
@@ -1,6 +1,6 @@
 /* AFS volume management
  *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2002, 2007 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -15,33 +15,9 @@
 #include <linux/slab.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
-#include "volume.h"
-#include "vnode.h"
-#include "cell.h"
-#include "cache.h"
-#include "cmservice.h"
-#include "fsclient.h"
-#include "vlclient.h"
 #include "internal.h"
=20
-#ifdef __KDEBUG
 static const char *afs_voltypes[] =3D { "R/W", "R/O", "BAK" };
-#endif
-
-#ifdef AFS_CACHING_SUPPORT
-static cachefs_match_val_t afs_volume_cache_match(void *target,
-						  const void *entry);
-static void afs_volume_cache_update(void *source, void *entry);
-
-struct cachefs_index_def afs_volume_cache_index_def =3D {
-	.name		=3D "volume",
-	.data_size	=3D sizeof(struct afs_cache_vhash),
-	.keys[0]	=3D { CACHEFS_INDEX_KEYS_BIN, 1 },
-	.keys[1]	=3D { CACHEFS_INDEX_KEYS_BIN, 1 },
-	.match		=3D afs_volume_cache_match,
-	.update		=3D afs_volume_cache_update,
-};
-#endif
=20
 /*
  * lookup a volume by name
@@ -65,11 +41,12 @@ struct cachefs_index_def afs_volume_cache_index_def=
 =3D {
  * - Rule 3: If parent volume is R/W, then only mount R/W volume unles=
s
  *           explicitly told otherwise
  */
-int afs_volume_lookup(const char *name, struct afs_cell *cell, int rwp=
ath,
-		      struct afs_volume **_volume)
+struct afs_volume *afs_volume_lookup(const char *name, struct afs_cell=
 *cell,
+				     int rwpath)
 {
 	struct afs_vlocation *vlocation =3D NULL;
 	struct afs_volume *volume =3D NULL;
+	struct afs_server *server =3D NULL;
 	afs_voltype_t type;
 	const char *cellname, *volname, *suffix;
 	char srvtmask;
@@ -79,7 +56,7 @@ int afs_volume_lookup(const char *name, struct afs_ce=
ll *cell, int rwpath,
=20
 	if (!name || (name[0] !=3D '%' && name[0] !=3D '#') || !name[1]) {
 		printk("kAFS: unparsable volume name\n");
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
 	}
=20
 	/* determine the type of volume we're looking for */
@@ -128,8 +105,9 @@ int afs_volume_lookup(const char *name, struct afs_=
cell *cell, int rwpath,
=20
 	/* lookup the cell record */
 	if (cellname || !cell) {
-		ret =3D afs_cell_lookup(cellname, cellnamesz, &cell);
-		if (ret<0) {
+		cell =3D afs_cell_lookup(cellname, cellnamesz);
+		if (IS_ERR(cell)) {
+			ret =3D PTR_ERR(cell);
 			printk("kAFS: unable to lookup cell '%s'\n",
 			       cellname ?: "");
 			goto error;
@@ -139,9 +117,12 @@ int afs_volume_lookup(const char *name, struct afs=
_cell *cell, int rwpath,
 	}
=20
 	/* lookup the volume location record */
-	ret =3D afs_vlocation_lookup(cell, volname, volnamesz, &vlocation);
-	if (ret < 0)
+	vlocation =3D afs_vlocation_lookup(cell, volname, volnamesz);
+	if (IS_ERR(vlocation)) {
+		ret =3D PTR_ERR(vlocation);
+		vlocation =3D NULL;
 		goto error;
+	}
=20
 	/* make the final decision on the type we want */
 	ret =3D -ENOMEDIUM;
@@ -192,13 +173,14 @@ int afs_volume_lookup(const char *name, struct af=
s_cell *cell, int rwpath,
 	/* look up all the applicable server records */
 	for (loop =3D 0; loop < 8; loop++) {
 		if (vlocation->vldb.srvtmask[loop] & (1 << volume->type)) {
-			ret =3D afs_server_lookup(
-				volume->cell,
-				&vlocation->vldb.servers[loop],
-				&volume->servers[volume->nservers]);
-			if (ret < 0)
+			server =3D afs_lookup_server(
+			       volume->cell, &vlocation->vldb.servers[loop]);
+			if (IS_ERR(server)) {
+				ret =3D PTR_ERR(server);
 				goto error_discard;
+			}
=20
+			volume->servers[volume->nservers] =3D server;
 			volume->nservers++;
 		}
 	}
@@ -219,8 +201,11 @@ int afs_volume_lookup(const char *name, struct afs=
_cell *cell, int rwpath,
 success:
 	_debug("kAFS selected %s volume %08x",
 	       afs_voltypes[volume->type], volume->vid);
-	*_volume =3D volume;
-	ret =3D 0;
+	up_write(&cell->vl_sem);
+	afs_put_vlocation(vlocation);
+	afs_put_cell(cell);
+	_leave(" =3D %p", volume);
+	return volume;
=20
 	/* clean up */
 error_up:
@@ -228,9 +213,8 @@ error_up:
 error:
 	afs_put_vlocation(vlocation);
 	afs_put_cell(cell);
-
-	_leave(" =3D %d (%p)", ret, volume);
-	return ret;
+	_leave(" =3D %d", ret);
+	return ERR_PTR(ret);
=20
 error_discard:
 	up_write(&cell->vl_sem);
@@ -255,10 +239,9 @@ void afs_put_volume(struct afs_volume *volume)
=20
 	_enter("%p", volume);
=20
-	vlocation =3D volume->vlocation;
+	ASSERTCMP(atomic_read(&volume->usage), >, 0);
=20
-	/* sanity check */
-	BUG_ON(atomic_read(&volume->usage) <=3D 0);
+	vlocation =3D volume->vlocation;
=20
 	/* to prevent a race, the decrement and the dequeue must be effective=
ly
 	 * atomic */
@@ -292,14 +275,21 @@ void afs_put_volume(struct afs_volume *volume)
  * pick a server to use to try accessing this volume
  * - returns with an elevated usage count on the server chosen
  */
-int afs_volume_pick_fileserver(struct afs_volume *volume,
-			       struct afs_server **_server)
+struct afs_server *afs_volume_pick_fileserver(struct afs_vnode *vnode)
 {
+	struct afs_volume *volume =3D vnode->volume;
 	struct afs_server *server;
 	int ret, state, loop;
=20
 	_enter("%s", volume->vlocation->vldb.name);
=20
+	/* stick with the server we're already using if we can */
+	if (vnode->server && vnode->server->fs_state =3D=3D 0) {
+		afs_get_server(vnode->server);
+		_leave(" =3D %p [current]", vnode->server);
+		return vnode->server;
+	}
+
 	down_read(&volume->server_sem);
=20
 	/* handle the no-server case */
@@ -307,7 +297,7 @@ int afs_volume_pick_fileserver(struct afs_volume *v=
olume,
 		ret =3D volume->rjservers ? -ENOMEDIUM : -ESTALE;
 		up_read(&volume->server_sem);
 		_leave(" =3D %d [no servers]", ret);
-		return ret;
+		return ERR_PTR(ret);
 	}
=20
 	/* basically, just search the list for the first live server and use
@@ -317,15 +307,16 @@ int afs_volume_pick_fileserver(struct afs_volume =
*volume,
 		server =3D volume->servers[loop];
 		state =3D server->fs_state;
=20
+		_debug("consider %d [%d]", loop, state);
+
 		switch (state) {
 			/* found an apparently healthy server */
 		case 0:
 			afs_get_server(server);
 			up_read(&volume->server_sem);
-			*_server =3D server;
-			_leave(" =3D 0 (picked %08x)",
-			       ntohl(server->addr.s_addr));
-			return 0;
+			_leave(" =3D %p (picked %08x)",
+			       server, ntohl(server->addr.s_addr));
+			return server;
=20
 		case -ENETUNREACH:
 			if (ret =3D=3D 0)
@@ -361,7 +352,7 @@ int afs_volume_pick_fileserver(struct afs_volume *v=
olume,
 	 */
 	up_read(&volume->server_sem);
 	_leave(" =3D %d", ret);
-	return ret;
+	return ERR_PTR(ret);
 }
=20
 /*
@@ -370,10 +361,11 @@ int afs_volume_pick_fileserver(struct afs_volume =
*volume,
  * - records result of using a particular server to access a volume
  * - return 0 to try again, 1 if okay or to issue error
  */
-int afs_volume_release_fileserver(struct afs_volume *volume,
+int afs_volume_release_fileserver(struct afs_vnode *vnode,
 				  struct afs_server *server,
 				  int result)
 {
+	struct afs_volume *volume =3D vnode->volume;
 	unsigned loop;
=20
 	_enter("%s,%08x,%d",
@@ -384,6 +376,7 @@ int afs_volume_release_fileserver(struct afs_volume=
 *volume,
 		/* success */
 	case 0:
 		server->fs_act_jif =3D jiffies;
+		server->fs_state =3D 0;
 		break;
=20
 		/* the fileserver denied all knowledge of the volume */
@@ -391,7 +384,7 @@ int afs_volume_release_fileserver(struct afs_volume=
 *volume,
 		server->fs_act_jif =3D jiffies;
 		down_write(&volume->server_sem);
=20
-		/* first, find where the server is in the active list (if it
+		/* firstly, find where the server is in the active list (if it
 		 * is) */
 		for (loop =3D 0; loop < volume->nservers; loop++)
 			if (volume->servers[loop] =3D=3D server)
@@ -429,6 +422,7 @@ int afs_volume_release_fileserver(struct afs_volume=
 *volume,
 	case -ENETUNREACH:
 	case -EHOSTUNREACH:
 	case -ECONNREFUSED:
+	case -ETIME:
 	case -ETIMEDOUT:
 	case -EREMOTEIO:
 		/* mark the server as dead
@@ -464,40 +458,3 @@ try_next_server:
 	_leave(" [try next server]");
 	return 0;
 }
-
-/*
- * match a volume hash record stored in the cache
- */
-#ifdef AFS_CACHING_SUPPORT
-static cachefs_match_val_t afs_volume_cache_match(void *target,
-						  const void *entry)
-{
-	const struct afs_cache_vhash *vhash =3D entry;
-	struct afs_volume *volume =3D target;
-
-	_enter("{%u},{%u}", volume->type, vhash->vtype);
-
-	if (volume->type =3D=3D vhash->vtype) {
-		_leave(" =3D SUCCESS");
-		return CACHEFS_MATCH_SUCCESS;
-	}
-
-	_leave(" =3D FAILED");
-	return CACHEFS_MATCH_FAILED;
-}
-#endif
-
-/*
- * update a volume hash record stored in the cache
- */
-#ifdef AFS_CACHING_SUPPORT
-static void afs_volume_cache_update(void *source, void *entry)
-{
-	struct afs_cache_vhash *vhash =3D entry;
-	struct afs_volume *volume =3D source;
-
-	_enter("");
-
-	vhash->vtype =3D volume->type;
-}
-#endif
diff --git a/fs/afs/volume.h b/fs/afs/volume.h
deleted file mode 100644
index a605bea..0000000
--- a/fs/afs/volume.h
+++ /dev/null
@@ -1,126 +0,0 @@
-/* AFS volume management
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef AFS_VOLUME_H
-#define AFS_VOLUME_H
-
-#include "types.h"
-#include "fsclient.h"
-#include "kafstimod.h"
-#include "kafsasyncd.h"
-#include "cache.h"
-
-typedef enum {
-	AFS_VLUPD_SLEEP,		/* sleeping waiting for update timer to fire */
-	AFS_VLUPD_PENDING,		/* on pending queue */
-	AFS_VLUPD_INPROGRESS,		/* op in progress */
-	AFS_VLUPD_BUSYSLEEP,		/* sleeping because server returned EBUSY */
-} __attribute__((packed)) afs_vlocation_upd_t;
-
-/*
- * entry in the cached volume location catalogue
- */
-struct afs_cache_vlocation {
-	uint8_t			name[64];	/* volume name (lowercase, padded with NULs) */
-	uint8_t			nservers;	/* number of entries used in servers[] */
-	uint8_t			vidmask;	/* voltype mask for vid[] */
-	uint8_t			srvtmask[8];	/* voltype masks for servers[] */
-#define AFS_VOL_VTM_RW	0x01 /* R/W version of the volume is available =
(on this server) */
-#define AFS_VOL_VTM_RO	0x02 /* R/O version of the volume is available =
(on this server) */
-#define AFS_VOL_VTM_BAK	0x04 /* backup version of the volume is availa=
ble (on this server) */
-
-	afs_volid_t		vid[3];		/* volume IDs for R/W, R/O and Bak volumes */
-	struct in_addr		servers[8];	/* fileserver addresses */
-	time_t			rtime;		/* last retrieval time */
-};
-
-#ifdef AFS_CACHING_SUPPORT
-extern struct cachefs_index_def afs_vlocation_cache_index_def;
-#endif
-
-/*
- * volume -> vnode hash table entry
- */
-struct afs_cache_vhash {
-	afs_voltype_t		vtype;		/* which volume variation */
-	uint8_t			hash_bucket;	/* which hash bucket this represents */
-} __attribute__((packed));
-
-#ifdef AFS_CACHING_SUPPORT
-extern struct cachefs_index_def afs_volume_cache_index_def;
-#endif
-
-/*
- * AFS volume location record
- */
-struct afs_vlocation {
-	atomic_t		usage;
-	struct list_head	link;		/* link in cell volume location list */
-	struct afs_timer	timeout;	/* decaching timer */
-	struct afs_cell		*cell;		/* cell to which volume belongs */
-#ifdef AFS_CACHING_SUPPORT
-	struct cachefs_cookie	*cache;		/* caching cookie */
-#endif
-	struct afs_cache_vlocation vldb;	/* volume information DB record */
-	struct afs_volume	*vols[3];	/* volume access record pointer (index by=
 type) */
-	rwlock_t		lock;		/* access lock */
-	unsigned long		read_jif;	/* time at which last read from vlserver */
-	struct afs_timer	upd_timer;	/* update timer */
-	struct afs_async_op	upd_op;		/* update operation */
-	afs_vlocation_upd_t	upd_state;	/* update state */
-	unsigned short		upd_first_svix;	/* first server index during update *=
/
-	unsigned short		upd_curr_svix;	/* current server index during update =
*/
-	unsigned short		upd_rej_cnt;	/* ENOMEDIUM count during update */
-	unsigned short		upd_busy_cnt;	/* EBUSY count during update */
-	unsigned short		valid;		/* T if valid */
-};
-
-extern int afs_vlocation_lookup(struct afs_cell *, const char *, unsig=
ned,
-				struct afs_vlocation **);
-
-#define afs_get_vlocation(V) do { atomic_inc(&(V)->usage); } while(0)
-
-extern void afs_put_vlocation(struct afs_vlocation *);
-extern void afs_vlocation_do_timeout(struct afs_vlocation *);
-
-/*
- * AFS volume access record
- */
-struct afs_volume {
-	atomic_t		usage;
-	struct afs_cell		*cell;		/* cell to which belongs (unrefd ptr) */
-	struct afs_vlocation	*vlocation;	/* volume location */
-#ifdef AFS_CACHING_SUPPORT
-	struct cachefs_cookie	*cache;		/* caching cookie */
-#endif
-	afs_volid_t		vid;		/* volume ID */
-	afs_voltype_t		type;		/* type of volume */
-	char			type_force;	/* force volume type (suppress R/O -> R/W) */
-	unsigned short		nservers;	/* number of server slots filled */
-	unsigned short		rjservers;	/* number of servers discarded due to -ENO=
MEDIUM */
-	struct afs_server	*servers[8];	/* servers on which volume resides (or=
dered) */
-	struct rw_semaphore	server_sem;	/* lock for accessing current server =
*/
-};
-
-extern int afs_volume_lookup(const char *, struct afs_cell *, int,
-			     struct afs_volume **);
-
-#define afs_get_volume(V) do { atomic_inc(&(V)->usage); } while(0)
-
-extern void afs_put_volume(struct afs_volume *);
-
-extern int afs_volume_pick_fileserver(struct afs_volume *,
-				      struct afs_server **);
-
-extern int afs_volume_release_fileserver(struct afs_volume *,
-					 struct afs_server *, int);
-
-#endif /* AFS_VOLUME_H */

