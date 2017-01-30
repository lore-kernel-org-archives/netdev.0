From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCHv3 perf/core 1/6] tools lib bpf: Add BPF program pinning
 APIs.
Date: Mon, 30 Jan 2017 17:25:06 -0300
Message-ID: <20170130202506.GF4546@kernel.org>
References: <20170126212001.14103-1-joe@ovn.org>
 <20170126212001.14103-2-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170126212001.14103-2-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Thu, Jan 26, 2017 at 01:19:56PM -0800, Joe Stringer escreveu:
> Add new APIs to pin a BPF program (or specific instances) to the filesystem.
> The user can specify the path full path within a BPF filesystem to pin the
> program.
> 
> bpf_program__pin_instance(prog, path, n) will pin the nth instance of
> 'prog' to the specified path.
> bpf_program__pin(prog, path) will create the directory 'path' (if it
> does not exist) and pin each instance within that directory. For
> instance, path/0, path/1, path/2.
> 
> Signed-off-by: Joe Stringer <joe@ovn.org>

make: Entering directory '/home/acme/git/linux/tools/perf'
  BUILD:   Doing 'make -j4' parallel build
  CC       /tmp/build/perf/builtin-record.o
  CC       /tmp/build/perf/libbpf.o
  CC       /tmp/build/perf/util/parse-events.o
  INSTALL  trace_plugins
libbpf.c: In function ‘make_dir’:
libbpf.c:1303:6: error: implicit declaration of function ‘mkdir’ [-Werror=implicit-function-declaration]
  if (mkdir(path, 0700) && errno != EEXIST)
      ^~~~~
libbpf.c:1303:2: error: nested extern declaration of ‘mkdir’ [-Werror=nested-externs]
  if (mkdir(path, 0700) && errno != EEXIST)
  ^~
cc1: all warnings being treated as errors
mv: cannot stat '/tmp/build/perf/.libbpf.o.tmp': No such file or directory
/home/acme/git/linux/tools/build/Makefile.build:101: recipe for target '/tmp/build/perf/libbpf.o' failed


And strdup() is not checked for failure, I'm fixing those,

+++ b/tools/lib/bpf/libbpf.c
@@ -36,6 +36,8 @@
 #include <linux/magic.h>
 #include <linux/list.h>
 #include <linux/limits.h>
+#include <sys/stat.h>
+#include <sys/types.h>
 #include <sys/vfs.h>


- Arnaldo

> ---
> v3: Add per-instance pinning.
>     Use path for bpf_program__pin() as directory.
> v2: Don't automount BPF filesystem
>     Split program, map, object pinning into separate APIs and separate
>     patches.
> ---
>  tools/lib/bpf/libbpf.c | 112 +++++++++++++++++++++++++++++++++++++++++++++++++
>  tools/lib/bpf/libbpf.h |   3 ++
>  2 files changed, 115 insertions(+)
> 
> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> index e6cd62b1264b..d1d7638b7c21 100644
> --- a/tools/lib/bpf/libbpf.c
> +++ b/tools/lib/bpf/libbpf.c
> @@ -4,6 +4,7 @@
>   * Copyright (C) 2013-2015 Alexei Starovoitov <ast@kernel.org>
>   * Copyright (C) 2015 Wang Nan <wangnan0@huawei.com>
>   * Copyright (C) 2015 Huawei Inc.
> + * Copyright (C) 2017 Nicira, Inc.
>   *
>   * This program is free software; you can redistribute it and/or
>   * modify it under the terms of the GNU Lesser General Public
> @@ -22,6 +23,7 @@
>  #include <stdlib.h>
>  #include <stdio.h>
>  #include <stdarg.h>
> +#include <libgen.h>
>  #include <inttypes.h>
>  #include <string.h>
>  #include <unistd.h>
> @@ -31,7 +33,10 @@
>  #include <linux/err.h>
>  #include <linux/kernel.h>
>  #include <linux/bpf.h>
> +#include <linux/magic.h>
>  #include <linux/list.h>
> +#include <linux/limits.h>
> +#include <sys/vfs.h>
>  #include <libelf.h>
>  #include <gelf.h>
>  
> @@ -1237,6 +1242,113 @@ int bpf_object__load(struct bpf_object *obj)
>  	return err;
>  }
>  
> +static int check_path(const char *path)
> +{
> +	struct statfs st_fs;
> +	char *dname, *dir;
> +	int err = 0;
> +
> +	if (path == NULL)
> +		return -EINVAL;
> +
> +	dname = strdup(path);
> +	dir = dirname(dname);
> +	if (statfs(dir, &st_fs)) {
> +		pr_warning("failed to statfs %s: %s\n", dir, strerror(errno));
> +		err = -errno;
> +	}
> +	free(dname);
> +
> +	if (!err && st_fs.f_type != BPF_FS_MAGIC) {
> +		pr_warning("specified path %s is not on BPF FS\n", path);
> +		err = -EINVAL;
> +	}
> +
> +	return err;
> +}
> +
> +int bpf_program__pin_instance(struct bpf_program *prog, const char *path,
> +			      int instance)
> +{
> +	int err;
> +
> +	err = check_path(path);
> +	if (err)
> +		return err;
> +
> +	if (prog == NULL) {
> +		pr_warning("invalid program pointer\n");
> +		return -EINVAL;
> +	}
> +
> +	if (instance < 0 || instance >= prog->instances.nr) {
> +		pr_warning("invalid prog instance %d of prog %s (max %d)\n",
> +			   instance, prog->section_name, prog->instances.nr);
> +		return -EINVAL;
> +	}
> +
> +	if (bpf_obj_pin(prog->instances.fds[instance], path)) {
> +		pr_warning("failed to pin program: %s\n", strerror(errno));
> +		return -errno;
> +	}
> +	pr_debug("pinned program '%s'\n", path);
> +
> +	return 0;
> +}
> +
> +static int make_dir(const char *path)
> +{
> +	int err = 0;
> +
> +	if (mkdir(path, 0700) && errno != EEXIST)
> +		err = -errno;
> +
> +	if (err)
> +		pr_warning("failed to mkdir %s: %s\n", path, strerror(-err));
> +	return err;
> +}
> +
> +int bpf_program__pin(struct bpf_program *prog, const char *path)
> +{
> +	int i, err;
> +
> +	err = check_path(path);
> +	if (err)
> +		return err;
> +
> +	if (prog == NULL) {
> +		pr_warning("invalid program pointer\n");
> +		return -EINVAL;
> +	}
> +
> +	if (prog->instances.nr <= 0) {
> +		pr_warning("no instances of prog %s to pin\n",
> +			   prog->section_name);
> +		return -EINVAL;
> +	}
> +
> +	err = make_dir(path);
> +	if (err)
> +		return err;
> +
> +	for (i = 0; i < prog->instances.nr; i++) {
> +		char buf[PATH_MAX];
> +		int len;
> +
> +		len = snprintf(buf, PATH_MAX, "%s/%d", path, i);
> +		if (len < 0)
> +			return -EINVAL;
> +		else if (len > PATH_MAX)
> +			return -ENAMETOOLONG;
> +
> +		err = bpf_program__pin_instance(prog, buf, i);
> +		if (err)
> +			return err;
> +	}
> +
> +	return 0;
> +}
> +
>  void bpf_object__close(struct bpf_object *obj)
>  {
>  	size_t i;
> diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
> index 4014d1ba5e3d..9f8aa63b95f4 100644
> --- a/tools/lib/bpf/libbpf.h
> +++ b/tools/lib/bpf/libbpf.h
> @@ -106,6 +106,9 @@ void *bpf_program__priv(struct bpf_program *prog);
>  const char *bpf_program__title(struct bpf_program *prog, bool needs_copy);
>  
>  int bpf_program__fd(struct bpf_program *prog);
> +int bpf_program__pin_instance(struct bpf_program *prog, const char *path,
> +			      int instance);
> +int bpf_program__pin(struct bpf_program *prog, const char *path);
>  
>  struct bpf_insn;
>  
> -- 
> 2.11.0
