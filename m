From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCHv2 perf/core 5/7] tools lib bpf: Add bpf_program__pin()
Date: Wed, 25 Jan 2017 09:04:16 +0800
Message-ID: <e24b0753-43ee-fad5-86c4-a3699caff05d@huawei.com>
References: <20170123011128.26534-1-joe@ovn.org>
 <20170123011128.26534-6-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ast@fb.com>, <daniel@iogearbox.net>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>, <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:41831 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdAYBFj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 20:05:39 -0500
In-Reply-To: <20170123011128.26534-6-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/1/23 9:11, Joe Stringer wrote:
> Add a new API to pin a BPF program to the filesystem. The user can
> specify the path full path within a BPF filesystem to pin the program.
> Programs with multiple instances are pinned as 'foo', 'foo_1', 'foo_2',
> and so on.
>
> Signed-off-by: Joe Stringer <joe@ovn.org>
> ---
> v2: Don't automount BPF filesystem
>      Split program, map, object pinning into separate APIs and separate
>      patches.
> ---
>   tools/lib/bpf/libbpf.c | 76 ++++++++++++++++++++++++++++++++++++++++++++++++++
>   tools/lib/bpf/libbpf.h |  1 +
>   2 files changed, 77 insertions(+)
>
> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> index e6cd62b1264b..eea5c74808f7 100644
> --- a/tools/lib/bpf/libbpf.c
> +++ b/tools/lib/bpf/libbpf.c
> @@ -4,6 +4,7 @@
>    * Copyright (C) 2013-2015 Alexei Starovoitov <ast@kernel.org>
>    * Copyright (C) 2015 Wang Nan <wangnan0@huawei.com>
>    * Copyright (C) 2015 Huawei Inc.
> + * Copyright (C) 2017 Nicira, Inc.
>    *
>    * This program is free software; you can redistribute it and/or
>    * modify it under the terms of the GNU Lesser General Public
> @@ -22,6 +23,7 @@
>   #include <stdlib.h>
>   #include <stdio.h>
>   #include <stdarg.h>
> +#include <libgen.h>
>   #include <inttypes.h>
>   #include <string.h>
>   #include <unistd.h>
> @@ -31,7 +33,10 @@
>   #include <linux/err.h>
>   #include <linux/kernel.h>
>   #include <linux/bpf.h>
> +#include <linux/magic.h>
>   #include <linux/list.h>
> +#include <linux/limits.h>
> +#include <sys/vfs.h>
>   #include <libelf.h>
>   #include <gelf.h>
>   
> @@ -1237,6 +1242,77 @@ int bpf_object__load(struct bpf_object *obj)
>   	return err;
>   }
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
> +int bpf_program__pin(struct bpf_program *prog, const char *path)

In your next patch please let caller select one instance:

int bpf_program__pin(struct bpf_program *prog, int instance, const char 
*path)
(please choose a better name)

Then your can wrap it with another function to pin all instances, implement
naming schema (%s_%d) there.

Then implement naming schema in bpf_object__pin like:

%s/objectname_mapname
%s/objectname_progname_%d

and make a bpf_{map,program}__pin the raw pinning functions with no 
naming schema.

Thank you.
