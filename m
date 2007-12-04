From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/4] DST: Distributed storage documentation.
Date: Tue, 4 Dec 2007 17:37:06 +0300
Message-ID: <11967790262216@2ka.mipt.ru>
References: <11967790263179@2ka.mipt.ru>
Reply-To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11967790263179@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Distributed storage documentation.

Algorithms used in the system, userspace interfaces
(sysfs dirs and files), design and implementation details
are described here.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>


diff --git a/Documentation/dst/algorithms.txt b/Documentation/dst/algorithms.txt
new file mode 100644
index 0000000..1437a6a
--- /dev/null
+++ b/Documentation/dst/algorithms.txt
@@ -0,0 +1,115 @@
+Each storage by itself is just a set of contiguous logical blocks, with
+allowed number of operations. Nodes, each of which has own start and size,
+are placed into storage by appropriate algorithm, which remaps
+logical sector number into real node's sector. One can create
+own algorithms, since DST has pluggable interface for that.
+Currently mirrored and linear algorithms are supported.
+
+Let's briefly describe how they work.
+
+Linear algorithm.
+Simple approach of concatenating storages into single device with
+increased size is used in this algorithm. Essentially new device
+has size equal to sum of sizes of underlying nodes and nodes are
+placed one after another.
+
+  /----- Node 1 ---\                         /------ Node 3 ----\
+start              end                     start               end
+ |==================|========================|==================|
+ |                start                     end                 |
+ |                  \------- Node 2 ---------/                  |
+ |                                                              |
+start                                                          end
+ \-------------------------- DST storage ----------------------/
+
+			        /\
+			        ||
+			        ||
+
+			   IO operations
+
+			    Figure 1. 
+     3 nodes combined into single storage using linear algorithm.
+
+Mirror algorithm.
+In this algorithms nodes are placed under each other, so when
+operation comes to the first one, it can be mirrored to all
+underlying nodes. In case of reading, actual data is obtained from
+the nearest node - algoritm keeps track of previous operation
+and knows where it was stopped, so that subsequent seek to the 
+start of the new request will take the shortest time.
+Writing is always mirrored to all underlying nodes.
+
+                  IO operations
+                       ||
+                       ||
+                       \/
+
+|---------------- DST storage -------------------|
+|      prev position                             |
+|-------|------------ Node 1 --------------------|
+|                              prev pos          |
+|-------------------- Node 2 -----|--------------|
+|prev pos                                        |
+|---|---------------- Node 3 --------------------|
+
+		Figure 2.
+   3 nodes combined into single storage using mirror algorithm.
+
+Each algorithm must implement number of callbacks,
+which must be registered during initialization time.
+
+struct dst_alg_ops
+{
+	int			(*add_node)(struct dst_node *n);
+	void			(*del_node)(struct dst_node *n);
+	int 			(*remap)(struct dst_request *req);
+	int			(*error)(struct kst_state *state, int err);
+	struct module 		*owner;
+};
+
+@add_node.
+This callback is invoked when new node is being added into the storage,
+but before node is actually added into the storage, so that it could
+be accessed from it. When it is called, all appropriate initialization
+of the underlying device is already completed (system has been connected
+to remote node or got a reference to the local block device). At this
+stage algorithm can add node into private map. 
+It must return zero on success or negative value otherwise.
+
+@del_node.
+This callback is invoked when node is being deleted from the storage,
+i.e. when its reference counter hits zero. It is called before
+any cleaning is performed.
+It must return zero on success or negative value otherwise.
+
+@remap.
+This callback is invoked each time new bio hits the storage.
+Request structure contains BIO itself, pointer to the node, which originally
+stores the whole region under given IO request, and various parameters
+used by storage core to process this block request.
+It must return zero on success or negative value otherwise. It is upto
+this method to call all cleaning if remapping failed, for example it must
+call kst_bio_endio() for given callback in case of error, which in turn
+will call bio_endio(). Note, that dst_request structure provided in this
+callback is allocated on stack, so if there is a need to use it outside
+of the given function, it must be cloned (it will happen automatically
+in state's push callback, but that copy will not be shared by any other
+user).
+
+@error.
+This callback is invoked for each error, which happend when processed
+requests for remote nodes or when talking to remote size
+of the local export node (state contains data related to data
+transfers over the network).
+If this function has fixed given error, it must return 0 or negative
+error value otherwise.
+
+@owner.
+This is module reference counter updated automatically by DST core.
+
+Algorithm must provide its name and above structure to the 
+dst_alloc_alg() function, which will return a reference to the newly
+created algorithm.
+To remove it, one needs to call dst_remove_alg() with given algorithm
+pointer.
diff --git a/Documentation/dst/dst.txt b/Documentation/dst/dst.txt
new file mode 100644
index 0000000..a6ea126
--- /dev/null
+++ b/Documentation/dst/dst.txt
@@ -0,0 +1,69 @@
+Distributed storage. Design and implementation.
+http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst
+
+	     Evgeniy Polyakov
+
+This document is intended to briefly describe design and
+implementation details of the distributed storage project,
+aimed to create ability to group physically and/or logically
+distributed storages into single device.
+
+Main operational unit in the storage is node. Node can represent
+either remote storage, connected to local machine, or local
+device, or storage exported to the outside of the system.
+Here goes small explaination of basic therms.
+
+Local node.
+This node is just a logical link between block device (with given
+major and minor numbers) and structure in the DST hierarchy,
+which represents number of sectors on the area, corresponding to given
+block device. it can be a disk, a device mapper node or stacked
+block device on top of another underlying DST nodes.
+
+Local export node.
+Essentially the same as local node, but it allows to access
+to its data via network. Remote clients can connect to given local 
+export node and read or write blocks according to its size.
+Blocks are then forwarded to underlying local node and processed
+there accordingly to the nature of the local node.
+
+Remote node.
+This type of nodes contain remotely accessible devices. One can think
+about remote nodes as remote disks, which can be connected to
+local system and combined into single storage. Remote nodes
+are presented as number of sectors accessed over the network
+by the local machine, where distributed storage is being formed.
+Remote node allows autoconfiguration - size of the storage and
+checksumming will be requested during node initialization (if remote
+node supports checksumming it will be turned on).
+
+
+Each node or set of them can be formed into single array, which
+in turn becomes a local node, which can be exported further by stacking
+a local export node on top of it.
+
+Each storage by itself is just a set of contiguous logical blocks, with
+allowed number of operations. Nodes, each of which has own start and size,
+are placed into storage by appropriate algorithm, which remaps
+logical sector number into real node's sector. One can create
+own algorithms, since DST has pluggable interface for that.
+Currently mirrored and linear algorithms are supported.
+One can find more details in Documentation/dst/algorithms.txt file.
+
+Main goal of the distributed storage is to combine remote nodes into
+single device, so each block IO request is being sent over the network
+(contrary requests for local nodes are handled by the gneric block
+layer features). Each network connection has number of variables which
+describe it (socket, list of requests, error handling and so on),
+which form kst_state structure. This network state is added into per-socket
+polling state machine, and can be processed by dedicated thread when
+becomes ready. This system forms asynchronous IO for given block
+requests. If block request can be processed without blocking, then
+no new structures are allocated and async part of the state is not used.
+
+When connection to the remote peer breaks, DST core tries to reconnect
+to failed node and no requests are marked as errorneous, instead
+they live in the queue until reconnectin is established.
+
+Userspace code, setup documentation and examples can be found on project's
+homepage above.
diff --git a/Documentation/dst/sysfs.txt b/Documentation/dst/sysfs.txt
new file mode 100644
index 0000000..79d79dc
--- /dev/null
+++ b/Documentation/dst/sysfs.txt
@@ -0,0 +1,30 @@
+This file describes sysfs files created for each storage.
+
+1. Per-storage files.
+Each storage has its own dir /sysfs/devices/$storage_name,
+which contains following files:
+
+alg - contains name of the algorithm used to created given storage
+name - name of the storage
+nodes - map of the storage (list of nodes and their sizes and starts)
+remove_all_nodes - writable file which allows to remove all nodes from given
+	storage
+n-$start-$cookie - per node directory, where
+	$start - start of the given node in sectors,
+	$cookie - unique node's id used by DST
+
+2. Per-node files.
+Node's files are located in /sysfs/devices/$storage_name/n-$start-$cookie
+directory, described above.
+
+chunks - private file for mirroring algorithm, contains map of update/dirty
+	sectors of the node, '-' means update, '+' is dirty and has to be
+	resynced sector
+clean - writable file, writing leads to marking node as clean (in sync)
+dirty - writable file, writing leads to marking node as dirty (not in sync)
+size - size of the given node in sectors
+start - start of the given node in the storage in sectors
+type - contains type of the node in the following format: $type: $dev
+	where $type is either 'L' or 'R' - local or remote acordingly,
+	and $dev is device name for local node (/dev/sda1 for example)
+	or address of the remote node (192.168.4.81:1025 for example)

