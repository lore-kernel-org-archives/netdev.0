From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v5 10/10] landlock: Add user and kernel documentation for Landlock
Date: Wed, 22 Feb 2017 02:26:32 +0100
Message-ID: <20170222012632.4196-11-mic@digikod.net>
References: <20170222012632.4196-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@k
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh.infomaniak.ch ([128.65.195.4]:59648 "EHLO
        smtp-sh.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753815AbdBVB2J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 20:28:09 -0500
In-Reply-To: <20170222012632.4196-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This documentation can be built with the Sphinx framework.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
---
 Documentation/security/index.rst           |   1 +
 Documentation/security/landlock/index.rst  |  19 ++
 Documentation/security/landlock/kernel.rst | 132 +++++++++++++
 Documentation/security/landlock/user.rst   | 298 +++++++++++++++++++++++++++++
 4 files changed, 450 insertions(+)
 create mode 100644 Documentation/security/landlock/index.rst
 create mode 100644 Documentation/security/landlock/kernel.rst
 create mode 100644 Documentation/security/landlock/user.rst

diff --git a/Documentation/security/index.rst b/Documentation/security/index.rst
index 9bae6bb20e7f..21a5a6b6e666 100644
--- a/Documentation/security/index.rst
+++ b/Documentation/security/index.rst
@@ -5,3 +5,4 @@ Security documentation
 .. toctree::
 
    tpm/index
+   landlock/index
diff --git a/Documentation/security/landlock/index.rst b/Documentation/security/landlock/index.rst
new file mode 100644
index 000000000000..012bb9c2e2cb
--- /dev/null
+++ b/Documentation/security/landlock/index.rst
@@ -0,0 +1,19 @@
+============
+Landlock LSM
+============
+
+Landlock is a stackable Linux Security Module (LSM) that makes it possible to
+create security sandboxes.  This kind of sandbox is expected to help mitigate
+the security impact of bugs or unexpected/malicious behaviors in user-space
+applications.  The current version allows only a process with the global
+CAP_SYS_ADMIN capability to create such sandboxes but the ultimate goal of
+Landlock is to empower any process, including unprivileged ones, to securely
+restrict themselves.  Landlock is inspired by seccomp-bpf but instead of
+filtering syscalls and their raw arguments, a Landlock rule can inspect the use
+of kernel objects like files and hence make a decision according to the kernel
+semantic.
+
+.. toctree::
+
+    user
+    kernel
diff --git a/Documentation/security/landlock/kernel.rst b/Documentation/security/landlock/kernel.rst
new file mode 100644
index 000000000000..d31a7d6574af
--- /dev/null
+++ b/Documentation/security/landlock/kernel.rst
@@ -0,0 +1,132 @@
+==============================
+Landlock: kernel documentation
+==============================
+
+eBPF properties
+===============
+
+To get an expressive language while still being safe and small, Landlock is
+based on eBPF. Landlock should be usable by untrusted processes and must
+therefore expose a minimal attack surface. The eBPF bytecode is minimal,
+powerful, widely used and designed to be used by untrusted applications. Thus,
+reusing the eBPF support in the kernel enables a generic approach while
+minimizing new code.
+
+An eBPF program has access to an eBPF context containing some fields including
+event arguments (i.e. arg1 and arg2). These arguments can be used directly or
+passed to helper functions according to their types. It is then possible to do
+complex access checks without race conditions or inconsistent evaluation (i.e.
+`incorrect mirroring of the OS code and state
+<https://www.internetsociety.org/doc/traps-and-pitfalls-practical-problems-system-call-interposition-based-security-tools>`_).
+
+A Landlock event describes a particular access type.  For now, there is only
+one event type dedicated to filesystem related operations:
+LANDLOCK_SUBTYPE_EVENT_FS.  A Landlock rule is tied to one event type.  This
+makes it possible to statically check context accesses, potentially performed
+by such rule, and hence prevents kernel address leaks and ensure the right use
+of event arguments with eBPF functions.  Any user can add multiple Landlock
+rules per Landlock event.  They are stacked and evaluated one after the other,
+starting from the most recent rule, as seccomp-bpf does with its filters.
+Underneath, an event is an abstraction over a set of LSM hooks.
+
+
+Guiding principles
+==================
+
+Unprivileged use
+----------------
+
+* Everything potentially security sensitive which is exposed to a Landlock
+  rule, through functions or context, shall have an associated ability flag to
+  specify which kind of privilege a process must have to load such a rule.
+* Every ability flag expresses a semantic goal (e.g. debug, process
+  introspection, process modification) potentially tied to a set of
+  capabilities.
+* Landlock helpers and context should be usable by any unprivileged and
+  untrusted rule while following the system security policy enforced by other
+  access control mechanisms (e.g. DAC, LSM).
+
+
+Landlock event and context
+--------------------------
+
+* A Landlock event shall be focused on access control on kernel objects instead
+  of syscall filtering (i.e. syscall arguments), which is the purpose of
+  seccomp-bpf.
+* A Landlock context provided by an event shall express the minimal interface
+  to control an access for a kernel object. This can be achieved by wrapping
+  this raw object (e.g. file, inode, path, dentry) with an abstract
+  representation (i.e. handle) for userland/bpfland.
+* An evolution of a context's field (e.g. new flags in the status field) shall
+  only be activated for a rule if the version specified by the loading thread
+  imply this behavior.  This makes it possible to ensure that the rule code
+  make sense (e.g.  only watch flags which may be activated).
+* An event type shall guaranty that all the BPF function calls from a rule are
+  safe.  Thus, the related Landlock context arguments shall always be of the
+  same type for a particular event type.  For example, a network event could
+  share helpers with a file event because of UNIX socket.  However, the same
+  helpers may not be compatible for a FS handle and a net handle.
+* Multiple event types may use the same context interface.
+
+
+Landlock helpers
+----------------
+
+* Landlock helpers shall be as generic as possible (i.e. using handles) while
+  at the same time being as simple as possible and following the syscall
+  creation principles (cf.  *Documentation/adding-syscalls.txt*).
+* The only behavior change allowed on a helper is to fix a (logical) bug to
+  match the initial semantic.
+* Helpers shall be reentrant, i.e. only take inputs from arguments (e.g. from
+  the BPF context) or from the current thread, to allow an event type to use a
+  cache.  Future rule options might change this cache behavior (e.g. invalidate
+  cache after some time).
+* It is quite easy to add new helpers to extend Landlock.  The main concern
+  should be about the possibility to leak information from a landlocked process
+  to another (e.g. through maps) to not reproduce the same security sensitive
+  behavior as ptrace(2).
+
+
+Rule addition and propagation
+=============================
+
+See :ref:`Documentation/security/landlock/user <inherited_rules>` for the
+intended goal of rule propagation.
+
+Structure definitions
+---------------------
+
+.. kernel-doc:: include/linux/landlock.h
+
+
+Functions for rule addition
+---------------------------
+
+.. kernel-doc:: security/landlock/manager.c
+
+
+Questions and answers
+=====================
+
+Why not create a custom event type for each kind of action?
+-----------------------------------------------------------
+
+Landlock rules can handle these checks.  Adding more exceptions to the kernel
+code would lead to more code complexity.  A decision to ignore a kind of action
+can and should be done at the beginning of a Landlock rule.
+
+
+Why a rule does not return an errno code?
+-----------------------------------------
+
+seccomp filters can return multiple kind of code, including an errno value,
+which may be convenient for access control.  Those return codes are hardwired
+in the userland ABI.  Instead, Landlock approach is to return a boolean to
+allow or deny an action, which is much simpler and more generic.  Moreover, we
+do not really have a choice because, unlike to seccomp, Landlock rules are not
+enforced at the syscall entry point but may be executed at any point in the
+kernel (through LSM hooks) where an errno return code may not make sense.
+However, with this simple ABI and with the ability to call helpers, Landlock
+may gain features similar to seccomp-bpf in the future while being compatible
+with previous rules.
+
diff --git a/Documentation/security/landlock/user.rst b/Documentation/security/landlock/user.rst
new file mode 100644
index 000000000000..3219aa1ed3a0
--- /dev/null
+++ b/Documentation/security/landlock/user.rst
@@ -0,0 +1,298 @@
+================================
+Landlock: userland documentation
+================================
+
+Landlock rules
+==============
+
+eBPF programs are used to create security rules.  They are contained and can
+call only a whitelist of dedicated functions. Moreover, they cannot loop, which
+protects from denial of service.  More information on BPF can be found in
+*Documentation/networking/filter.txt*.
+
+
+Writing a rule
+--------------
+
+To enforce a security policy, a thread first needs to create a Landlock rule.
+The easiest way to write an eBPF program depicting a security rule is to write
+it in the C language.  As described in *samples/bpf/README.rst*, LLVM can
+compile such programs.  Files *samples/bpf/landlock1_kern.c* and those in
+*tools/testing/selftests/landlock/rules/* can be used as examples.  The
+following example is a simple rule to forbid file creation, whatever syscall
+may be used (e.g. open, mkdir, link...).
+
+.. code-block:: c
+
+    static int deny_file_creation(struct landlock_context *ctx)
+    {
+        if (ctx->arg2 & LANDLOCK_ACTION_FS_NEW)
+            return 1;
+        return 0;
+    }
+
+Once the eBPF program is created, the next step is to create the metadata
+describing the Landlock rule.  This metadata includes a subtype which contains
+the version of Landlock, the event to which the rule is tied, and optional
+Landlock rule abilities.
+
+.. code-block:: c
+
+    static union bpf_prog_subtype subtype = {
+        .landlock_rule = {
+            .version = 1,
+            .event = LANDLOCK_SUBTYPE_EVENT_FS,
+        }
+    };
+
+The Landlock version is important to inform the kernel which features or
+behavior the rule can handle.  The user-space thread should set the lowest
+possible version to be as compatible as possible with older kernels.  For the
+list of features provided by version, see :ref:`features`.
+
+A Landlock event describes the kind of kernel object for which a rule will be
+triggered to allow or deny an action.  For example, the event
+LANDLOCK_SUBTYPE_EVENT_FS is triggered every time a landlocked thread performs
+an action related to the filesystem (e.g. open, read, write, mount...).
+
+The Landlock rule abilities should only be used if the rule needs a specific
+feature such as debugging.  This should be avoided if not strictly necessary.
+
+The next step is to fill a :c:type:`union bpf_attr <bpf_attr>` with
+BPF_PROG_TYPE_LANDLOCK, the previously created subtype and other BPF program
+metadata.  This bpf_attr must then be passed to the bpf(2) syscall alongside
+the BPF_PROG_LOAD command.  If everything is deemed correct by the kernel, the
+thread gets a file descriptor referring to this rule.
+
+In the following code, the *insn* variable is an array of BPF instructions
+which can be extracted from an ELF file as is done in bpf_load_file() from
+*samples/bpf/bpf_load.c*.
+
+.. code-block:: c
+
+    union bpf_attr attr = {
+        .prog_type = BPF_PROG_TYPE_LANDLOCK,
+        .insn_cnt = sizeof(insn) / sizeof(struct bpf_insn),
+        .insns = (__u64) (unsigned long) insn,
+        .license = (__u64) (unsigned long) "GPL",
+        .prog_subtype = &subtype,
+    };
+    int rule = bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
+    if (rule == -1)
+        exit(1);
+
+
+Enforcing a rule
+----------------
+
+Once the Landlock rule has been created or received (e.g. through a UNIX
+socket), the thread willing to sandbox itself (and its future children) needs
+to perform two steps to properly enforce a rule.
+
+The thread must first request to never be allowed to get new privileges with a
+call to prctl(2) and the PR_SET_NO_NEW_PRIVS option.  More information can be
+found in *Documentation/prctl/no_new_privs.txt*.
+
+.. code-block:: c
+
+    if (prctl(PR_SET_NO_NEW_PRIVS, 1, NULL, 0, 0))
+        exit(1);
+
+A thread can apply a rule to itself by using the seccomp(2) syscall.  The
+operation is SECCOMP_ADD_LANDLOCK_RULE, the flags must be empty and the *args*
+argument must point to a valid Landlock rule file descriptor.
+
+.. code-block:: c
+
+    if (seccomp(SECCOMP_ADD_LANDLOCK_RULE, 0, &rule))
+        exit(1);
+
+If the syscall succeeds, the rule is now enforced on the calling thread and
+will be enforced on all its subsequently created children of the thread as
+well.  Once a thread is landlocked, there is no way to remove this security
+policy, only stacking more restrictions is allowed.
+
+
+.. _inherited_rules:
+
+Inherited rules
+---------------
+
+Every new thread resulting from a clone(2) inherits Landlock rule restrictions
+from its parent.  This is comparable to the seccomp inheritance as described in
+*Documentation/prctl/seccomp_filter.txt*, but differs for rules addition.
+
+If a thread adds a rule for a particular event, then all its future children
+and their progeny will inherit all the rules from the same event, whether any
+of those rules were added before or after the fork.  This allows a thread to
+share its security policy with its children and further restrict them over
+time.  If a thread wants its future rules to be propagated, it must then create
+at least one rule tied to the same event before any fork.
+
+
+.. _features:
+
+Landlock features
+=================
+
+In order to support new features over time without changing a rule behavior,
+every context field, flag or helpers has a minimal Landlock version in which
+they are available.  A thread needs to specify this minimal version number in
+the subtype :c:type:`struct landlock_rule <landlock_rule>` defined in
+*include/uapi/linux/bpf.h*.
+
+
+Context
+-------
+
+The arch and syscall_nr fields may be useful to tighten an access control, but
+care must be taken to avoid pitfalls as explain in
+*Documentation/prctl/seccomp_filter.txt*.
+
+.. kernel-doc:: include/uapi/linux/bpf.h
+    :functions: landlock_context
+
+
+Landlock event types
+--------------------
+
+.. kernel-doc:: include/uapi/linux/bpf.h
+    :functions: landlock_subtype_event
+
+.. flat-table:: Event types availability
+
+    * - flags
+      - since
+
+    * - LANDLOCK_SUBTYPE_EVENT_FS
+      - v1
+
+
+File system access request
+--------------------------
+
+Optional arguments from :c:type:`struct landlock_context <landlock_context>`:
+
+* arg1: filesystem handle
+* arg2: action type
+
+
+File system action types
+------------------------
+
+Flags are used to express actions.  This makes it possible to compose actions
+and leaves room for future improvements to add more fine-grained action types.
+
+.. kernel-doc:: include/uapi/linux/bpf.h
+    :doc: landlock_action_fs
+
+.. flat-table:: FS action types availability
+
+    * - flags
+      - since
+
+    * - LANDLOCK_ACTION_FS_EXEC
+      - v1
+
+    * - LANDLOCK_ACTION_FS_WRITE
+      - v1
+
+    * - LANDLOCK_ACTION_FS_READ
+      - v1
+
+    * - LANDLOCK_ACTION_FS_NEW
+      - v1
+
+    * - LANDLOCK_ACTION_FS_GET
+      - v1
+
+    * - LANDLOCK_ACTION_FS_REMOVE
+      - v1
+
+    * - LANDLOCK_ACTION_FS_IOCTL
+      - v1
+
+    * - LANDLOCK_ACTION_FS_LOCK
+      - v1
+
+    * - LANDLOCK_ACTION_FS_FCNTL
+      - v1
+
+
+Ability types
+-------------
+
+The ability of a Landlock rule describes the available features (i.e. context
+fields and helpers).  This is useful to abstract user-space privileges for
+Landlock rules, which may not need all abilities (e.g. debug).  Only the
+minimal set of abilities should be used (e.g. disable debug once in
+production).
+
+
+.. kernel-doc:: include/uapi/linux/bpf.h
+    :doc: landlock_subtype_ability
+
+.. flat-table:: Ability types availability
+
+    * - flags
+      - since
+      - capability
+
+    * - LANDLOCK_SUBTYPE_ABILITY_WRITE
+      - v1
+      - CAP_SYS_ADMIN
+
+    * - LANDLOCK_SUBTYPE_ABILITY_DEBUG
+      - v1
+      - CAP_SYS_ADMIN
+
+
+Helper functions
+----------------
+
+See *include/uapi/linux/bpf.h* for functions documentation.
+
+.. flat-table:: Generic functions availability
+
+    * - helper
+      - since
+      - ability
+
+    * - bpf_map_lookup_elem
+      - v1
+      - (none)
+
+    * - bpf_map_delete_elem
+      - v1
+      - LANDLOCK_SUBTYPE_ABILITY_WRITE
+
+    * - bpf_map_update_elem
+      - v1
+      - LANDLOCK_SUBTYPE_ABILITY_WRITE
+
+    * - bpf_get_current_comm
+      - v1
+      - LANDLOCK_SUBTYPE_ABILITY_DEBUG
+
+    * - bpf_get_current_pid_tgid
+      - v1
+      - LANDLOCK_SUBTYPE_ABILITY_DEBUG
+
+    * - bpf_get_current_uid_gid
+      - v1
+      - LANDLOCK_SUBTYPE_ABILITY_DEBUG
+
+    * - bpf_get_trace_printk
+      - v1
+      - LANDLOCK_SUBTYPE_ABILITY_DEBUG
+
+.. flat-table:: File system functions availability
+
+    * - helper
+      - since
+      - ability
+
+    * - bpf_handle_fs_get_mode
+      - v1
+      - (none)
+
-- 
2.11.0
