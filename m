From: David Howells <dhowells@redhat.com>
Subject: [PATCH 12/16] AFS: Update the AFS fs documentation [try #3]
Date: Wed, 25 Apr 2007 11:51:39 +0100
Message-ID: <20070425105139.10872.89416.stgit@warthog.cambridge.redhat.com>
References: <20070425105036.10872.48596.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S2992675AbXDYKyM@vger.kernel.org>
In-Reply-To: <20070425105036.10872.48596.stgit@warthog.cambridge.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the AFS fs documentation.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 Documentation/filesystems/afs.txt |  214 +++++++++++++++++++++++++++----------
 1 files changed, 154 insertions(+), 60 deletions(-)

diff --git a/Documentation/filesystems/afs.txt b/Documentation/filesystems/afs.txt
index 2f4237d..12ad6c7 100644
--- a/Documentation/filesystems/afs.txt
+++ b/Documentation/filesystems/afs.txt
@@ -1,31 +1,82 @@
+			     ====================
 			     kAFS: AFS FILESYSTEM
 			     ====================
 
-ABOUT
-=====
+Contents:
+
+ - Overview.
+ - Usage.
+ - Mountpoints.
+ - Proc filesystem.
+ - The cell database.
+ - Security.
+ - Examples.
+
+
+========
+OVERVIEW
+========
 
-This filesystem provides a fairly simple AFS filesystem driver. It is under
-development and only provides very basic facilities. It does not yet support
-the following AFS features:
+This filesystem provides a fairly simple secure AFS filesystem driver. It is
+under development and does not yet provide the full feature set.  The features
+it does support include:
 
-	(*) Write support.
-	(*) Communications security.
-	(*) Local caching.
-	(*) pioctl() system call.
-	(*) Automatic mounting of embedded mountpoints.
+ (*) Security (currently only AFS kaserver and KerberosIV tickets).
 
+ (*) File reading.
 
+ (*) Automounting.
+
+It does not yet support the following AFS features:
+
+ (*) Write support.
+
+ (*) Local caching.
+
+ (*) pioctl() system call.
+
+
+===========
+COMPILATION
+===========
+
+The filesystem should be enabled by turning on the kernel configuration
+options:
+
+	CONFIG_AF_RXRPC		- The RxRPC protocol transport
+	CONFIG_RXKAD		- The RxRPC Kerberos security handler
+	CONFIG_AFS		- The AFS filesystem
+
+Additionally, the following can be turned on to aid debugging:
+
+	CONFIG_AF_RXRPC_DEBUG	- Permit AF_RXRPC debugging to be enabled
+	CONFIG_AFS_DEBUG	- Permit AFS debugging to be enabled
+
+They permit the debugging messages to be turned on dynamically by manipulating
+the masks in the following files:
+
+	/sys/module/af_rxrpc/parameters/debug
+	/sys/module/afs/parameters/debug
+
+
+=====
 USAGE
 =====
 
 When inserting the driver modules the root cell must be specified along with a
 list of volume location server IP addresses:
 
-	insmod rxrpc.o
+	insmod af_rxrpc.o
+	insmod rxkad.o
 	insmod kafs.o rootcell=cambridge.redhat.com:172.16.18.73:172.16.18.91
 
-The first module is a driver for the RxRPC remote operation protocol, and the
-second is the actual filesystem driver for the AFS filesystem.
+The first module is the AF_RXRPC network protocol driver.  This provides the
+RxRPC remote operation protocol and may also be accessed from userspace.  See:
+
+	Documentation/networking/rxrpc.txt
+
+The second module is the kerberos RxRPC security driver, and the third module
+is the actual filesystem driver for the AFS filesystem.
 
 Once the module has been loaded, more modules can be added by the following
 procedure:
@@ -33,7 +84,7 @@ procedure:
 	echo add grand.central.org 18.7.14.88:128.2.191.224 >/proc/fs/afs/cells
 
 Where the parameters to the "add" command are the name of a cell and a list of
-volume location servers within that cell.
+volume location servers within that cell, with the latter separated by colons.
 
 Filesystems can be mounted anywhere by commands similar to the following:
 
@@ -42,11 +93,6 @@ Filesystems can be mounted anywhere by commands similar to the following:
 	mount -t afs "#root.afs." /afs
 	mount -t afs "#root.cell." /afs/cambridge
 
-  NB: When using this on Linux 2.4, the mount command has to be different,
-      since the filesystem doesn't have access to the device name argument:
-
-	mount -t afs none /afs -ovol="#root.afs."
-
 Where the initial character is either a hash or a percent symbol depending on
 whether you definitely want a R/W volume (hash) or whether you'd prefer a R/O
 volume, but are willing to use a R/W volume instead (percent).
@@ -60,55 +106,66 @@ named volume will be looked up in the cell specified during insmod.
 Additional cells can be added through /proc (see later section).
 
 
+===========
 MOUNTPOINTS
 ===========
 
-AFS has a concept of mountpoints. These are specially formatted symbolic links
-(of the same form as the "device name" passed to mount). kAFS presents these
-to the user as directories that have special properties:
+AFS has a concept of mountpoints. In AFS terms, these are specially formatted
+symbolic links (of the same form as the "device name" passed to mount).  kAFS
+presents these to the user as directories that have a follow-link capability
+(ie: symbolic link semantics).  If anyone attempts to access them, they will
+automatically cause the target volume to be mounted (if possible) on that site.
 
-  (*) They cannot be listed. Running a program like "ls" on them will incur an
-      EREMOTE error (Object is remote).
+Automatically mounted filesystems will be automatically unmounted approximately
+twenty minutes after they were last used.  Alternatively they can be unmounted
+directly with the umount() system call.
 
-  (*) Other objects can't be looked up inside of them. This also incurs an
-      EREMOTE error.
+Manually unmounting an AFS volume will cause any idle submounts upon it to be
+culled first.  If all are culled, then the requested volume will also be
+unmounted, otherwise error EBUSY will be returned.
 
-  (*) They can be queried with the readlink() system call, which will return
-      the name of the mountpoint to which they point. The "readlink" program
-      will also work.
+This can be used by the administrator to attempt to unmount the whole AFS tree
+mounted on /afs in one go by doing:
 
-  (*) They can be mounted on (which symbolic links can't).
+	umount /afs
 
 
+===============
 PROC FILESYSTEM
 ===============
 
-The rxrpc module creates a number of files in various places in the /proc
-filesystem:
-
-  (*) Firstly, some information files are made available in a directory called
-      "/proc/net/rxrpc/". These list the extant transport endpoint, peer,
-      connection and call records.
-
-  (*) Secondly, some control files are made available in a directory called
-      "/proc/sys/rxrpc/". Currently, all these files can be used for is to
-      turn on various levels of tracing.
-
 The AFS modules creates a "/proc/fs/afs/" directory and populates it:
 
-  (*) A "cells" file that lists cells currently known to the afs module.
+  (*) A "cells" file that lists cells currently known to the afs module and
+      their usage counts:
+
+	[root@andromeda ~]# cat /proc/fs/afs/cells
+	USE NAME
+	  3 cambridge.redhat.com
 
   (*) A directory per cell that contains files that list volume location
       servers, volumes, and active servers known within that cell.
 
+	[root@andromeda ~]# cat /proc/fs/afs/cambridge.redhat.com/servers
+	USE ADDR            STATE
+	  4 172.16.18.91        0
+	[root@andromeda ~]# cat /proc/fs/afs/cambridge.redhat.com/vlservers
+	ADDRESS
+	172.16.18.91
+	[root@andromeda ~]# cat /proc/fs/afs/cambridge.redhat.com/volumes
+	USE STT VLID[0]  VLID[1]  VLID[2]  NAME
+	  1 Val 20000000 20000001 20000002 root.afs
 
+
+=================
 THE CELL DATABASE
 =================
 
-The filesystem maintains an internal database of all the cells it knows and
-the IP addresses of the volume location servers for those cells. The cell to
-which the computer belongs is added to the database when insmod is performed
-by the "rootcell=" argument.
+The filesystem maintains an internal database of all the cells it knows and the
+IP addresses of the volume location servers for those cells.  The cell to which
+the system belongs is added to the database when insmod is performed by the
+"rootcell=" argument or, if compiled in, using a "kafs.rootcell=" argument on
+the kernel command line.
 
 Further cells can be added by commands similar to the following:
 
@@ -118,20 +175,65 @@ Further cells can be added by commands similar to the following:
 No other cell database operations are available at this time.
 
 
+========
+SECURITY
+========
+
+Secure operations are initiated by acquiring a key using the klog program.  A
+very primitive klog program is available at:
+
+	http://people.redhat.com/~dhowells/rxrpc/klog.c
+
+This should be compiled by:
+
+	make klog LDLIBS="-lcrypto -lcrypt -lkrb4 -lkeyutils"
+
+And then run as:
+
+	./klog
+
+Assuming it's successful, this adds a key of type RxRPC, named for the service
+and cell, eg: "afs@<cellname>".  This can be viewed with the keyctl program or
+by cat'ing /proc/keys:
+
+	[root@andromeda ~]# keyctl show
+	Session Keyring
+	       -3 --alswrv      0     0  keyring: _ses.3268
+		2 --alswrv      0     0   \_ keyring: _uid.0
+	111416553 --als--v      0     0   \_ rxrpc: afs@CAMBRIDGE.REDHAT.COM
+
+Currently the username, realm, password and proposed ticket lifetime are
+compiled in to the program.
+
+It is not required to acquire a key before using AFS facilities, but if one is
+not acquired then all operations will be governed by the anonymous user parts
+of the ACLs.
+
+If a key is acquired, then all AFS operations, including mounts and automounts,
+made by a possessor of that key will be secured with that key.
+
+If a file is opened with a particular key and then the file descriptor is
+passed to a process that doesn't have that key (perhaps over an AF_UNIX
+socket), then the operations on the file will be made with key that was used to
+open the file.
+
+
+========
 EXAMPLES
 ========
 
-Here's what I use to test this. Some of the names and IP addresses are local
-to my internal DNS. My "root.afs" partition has a mount point within it for
+Here's what I use to test this.  Some of the names and IP addresses are local
+to my internal DNS.  My "root.afs" partition has a mount point within it for
 some public volumes volumes.
 
-insmod -S /tmp/rxrpc.o 
-insmod -S /tmp/kafs.o rootcell=cambridge.redhat.com:172.16.18.73:172.16.18.91
+insmod /tmp/rxrpc.o
+insmod /tmp/rxkad.o
+insmod /tmp/kafs.o rootcell=cambridge.redhat.com:172.16.18.91
 
 mount -t afs \%root.afs. /afs
 mount -t afs \%cambridge.redhat.com:root.cell. /afs/cambridge.redhat.com/
 
-echo add grand.central.org 18.7.14.88:128.2.191.224 > /proc/fs/afs/cells 
+echo add grand.central.org 18.7.14.88:128.2.191.224 > /proc/fs/afs/cells
 mount -t afs "#grand.central.org:root.cell." /afs/grand.central.org/
 mount -t afs "#grand.central.org:root.archive." /afs/grand.central.org/archive
 mount -t afs "#grand.central.org:root.contrib." /afs/grand.central.org/contrib
@@ -141,15 +243,7 @@ mount -t afs "#grand.central.org:root.service." /afs/grand.central.org/service
 mount -t afs "#grand.central.org:root.software." /afs/grand.central.org/software
 mount -t afs "#grand.central.org:root.user." /afs/grand.central.org/user
 
-umount /afs/grand.central.org/user
-umount /afs/grand.central.org/software
-umount /afs/grand.central.org/service
-umount /afs/grand.central.org/project
-umount /afs/grand.central.org/doc
-umount /afs/grand.central.org/contrib
-umount /afs/grand.central.org/archive
-umount /afs/grand.central.org
-umount /afs/cambridge.redhat.com
 umount /afs
 rmmod kafs
+rmmod rxkad
 rmmod rxrpc
