From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 3/4] doc/bpf: describes the different types of eBPF
 maps available
Date: Tue, 07 Feb 2017 15:30:27 +0100
Message-ID: <148647782713.10567.13108187306600978138.stgit@localhost>
References: <148647756092.10567.10947541548678801938.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, alexander@alemayhu.com,
        linux-kernel@vger.kernel.org, quentin.monnet@6wind.com,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>
To: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        Jonathan Corbet <corbet@lwn.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148647756092.10567.10947541548678801938.stgit@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The purpose is to help choose the right map type based on the
individual use-case.

To start with, only BPF_MAP_TYPE_ARRAY is described. It is the plan
that all types should have descriptions here.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 Documentation/bpf/ebpf_maps.rst       |    3 +
 Documentation/bpf/ebpf_maps_types.rst |  119 +++++++++++++++++++++++++++++++++
 Documentation/bpf/index.rst           |    1 
 3 files changed, 122 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/bpf/ebpf_maps_types.rst

diff --git a/Documentation/bpf/ebpf_maps.rst b/Documentation/bpf/ebpf_maps.rst
index b8808f3bc31c..a5ba49f07cf5 100644
--- a/Documentation/bpf/ebpf_maps.rst
+++ b/Documentation/bpf/ebpf_maps.rst
@@ -4,7 +4,8 @@ eBPF maps
 
 This document describes what eBPF maps are, how you create them
 (`Creating a map`_), and how to interact with them (`Interacting with
-maps`_).
+maps`_).  The different map types available are described here:
+:doc:`ebpf_maps_types`.
 
 Using eBPF maps is a method to keep state between invocations of the
 eBPF program, and allows sharing data between eBPF kernel programs,
diff --git a/Documentation/bpf/ebpf_maps_types.rst b/Documentation/bpf/ebpf_maps_types.rst
new file mode 100644
index 000000000000..82136efecb04
--- /dev/null
+++ b/Documentation/bpf/ebpf_maps_types.rst
@@ -0,0 +1,119 @@
+==================
+Types of eBPF maps
+==================
+
+This document describes the different types of eBPF maps available,
+and goes into details about the individual map types.  The purpose is
+to help choose the right type based on the individual use-case.
+Creating and interacting with maps are described in another document
+here: :doc:`ebpf_maps`.
+
+The different types of maps available, are defined by ``enum
+bpf_map_type`` in include/uapi/linux/bpf.h.  These type definition
+"names" are needed when creating the map. Example of ``bpf_map_type``,
+but remember to `lookup latest`_ available maps in the source code.
+
+.. code-block:: c
+
+ enum bpf_map_type {
+	BPF_MAP_TYPE_UNSPEC,
+	BPF_MAP_TYPE_HASH,
+	BPF_MAP_TYPE_ARRAY,
+	BPF_MAP_TYPE_PROG_ARRAY,
+	BPF_MAP_TYPE_PERF_EVENT_ARRAY,
+	BPF_MAP_TYPE_PERCPU_HASH,
+	BPF_MAP_TYPE_PERCPU_ARRAY,
+	BPF_MAP_TYPE_STACK_TRACE,
+	BPF_MAP_TYPE_CGROUP_ARRAY,
+	BPF_MAP_TYPE_LRU_HASH,
+	BPF_MAP_TYPE_LRU_PERCPU_HASH,
+ };
+
+.. section links
+
+.. _lookup latest:
+   http://lxr.free-electrons.com/ident?i=bpf_map_type
+
+Implementation details
+======================
+
+In-order to understand and follow the descriptions of the different
+map types, in is useful for the reader to understand how a map type is
+implemented by the kernel.
+
+On the kernel side, implementing a map type requires defining some
+function call (pointers) via `struct bpf_map_ops`_.  The eBPF programs
+(and userspace) have access to the functions calls
+``map_lookup_elem``, ``map_update_elem`` and ``map_delete_elem``,
+which get invoked from eBPF via bpf-helpers in `kernel/bpf/helpers.c`_,
+or via userspace the bpf syscall (as described in :doc:`ebpf_maps`).
+
+:ref:`Creating a map` requires supplying the following configuration
+attributes: map_type, key_size, value_size, max_entries and map_flags.
+
+.. section links
+
+.. _struct bpf_map_ops: http://lxr.free-electrons.com/ident?i=bpf_map_ops
+
+.. _kernel/bpf/helpers.c:
+   https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/kernel/bpf/helpers.c
+
+
+BPF_MAP_TYPE_ARRAY
+==================
+
+Implementation defined in `kernel/bpf/arraymap.c`_ via struct
+bpf_map_ops `array_ops`_.
+
+As the name ``BPF_MAP_TYPE_ARRAY`` indicates, this can be seen as an
+array.  All array elements are pre-allocated and zero initialized at
+init time.  Key is an index in array and can only be 4 bytes (32-bit).
+The constant size is defined by ``max_entries``.  This init-time
+constant also implies bpf_map_delete_elem (`array_map_delete_elem`_)
+is an invalid operation.
+
+Optimized for fastest possible lookup. The size is constant for the
+life of the eBPF program, which allows verifier+JIT to perform a wider
+range of optimizations.  E.g. `array_map_lookup_elem()`_ may be
+'inlined' by JIT.
+
+Small size gotcha, the ``value_size`` is rounded up to 8 bytes.
+
+Example usage BPF_MAP_TYPE_ARRAY, based on `samples/bpf/sockex1_kern.c`_:
+
+.. code-block:: c
+
+  struct bpf_map_def SEC("maps") my_map = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = 256,
+  };
+
+  u32 index = 42;
+  long *value;
+  value = bpf_map_lookup_elem(&my_map, &index);
+	if (value)
+		__sync_fetch_and_add(value, 1);
+
+The lookup (from kernel side) ``bpf_map_lookup_elem()`` returns a pointer
+into the array element.  To avoid data races with userspace reading
+the value, the API-user must use primitives like ``__sync_fetch_and_add()``
+when updating the value in-place.
+
+.. section links
+
+.. _kernel/bpf/arraymap.c:
+   http://lxr.free-electrons.com/source/kernel/bpf/arraymap.c
+
+.. _array_ops:
+   http://lxr.free-electrons.com/ident?i=array_ops
+
+.. _array_map_delete_elem:
+   http://lxr.free-electrons.com/ident?i=array_map_delete_elem
+
+.. _array_map_lookup_elem():
+   http://lxr.free-electrons.com/ident?i=array_map_lookup_elem
+
+.. _samples/bpf/sockex1_kern.c:
+   https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/samples/bpf/sockex1_kern.c
diff --git a/Documentation/bpf/index.rst b/Documentation/bpf/index.rst
index 738d17aaf6d7..618a28f7e959 100644
--- a/Documentation/bpf/index.rst
+++ b/Documentation/bpf/index.rst
@@ -43,6 +43,7 @@ covered by this documentation.
    :maxdepth: 1
 
    ebpf_maps
+   ebpf_maps_types
 
 .. links:
 
