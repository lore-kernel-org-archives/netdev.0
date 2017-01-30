From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCHv3 perf/core 1/6] tools lib bpf: Add BPF program pinning
 APIs.
Date: Mon, 30 Jan 2017 17:28:13 -0300
Message-ID: <20170130202813.GG4546@kernel.org>
References: <20170126212001.14103-1-joe@ovn.org>
 <20170126212001.14103-2-joe@ovn.org>
 <20170130202506.GF4546@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170130202506.GF4546@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Jan 30, 2017 at 05:25:06PM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Thu, Jan 26, 2017 at 01:19:56PM -0800, Joe Stringer escreveu:
> > Add new APIs to pin a BPF program (or specific instances) to the filesystem.
> > The user can specify the path full path within a BPF filesystem to pin the
> > program.
> > 
> > bpf_program__pin_instance(prog, path, n) will pin the nth instance of
> > 'prog' to the specified path.
> > bpf_program__pin(prog, path) will create the directory 'path' (if it
> > does not exist) and pin each instance within that directory. For
> > instance, path/0, path/1, path/2.
> > 
> > Signed-off-by: Joe Stringer <joe@ovn.org>
> 
> make: Entering directory '/home/acme/git/linux/tools/perf'
>   BUILD:   Doing 'make -j4' parallel build
>   CC       /tmp/build/perf/builtin-record.o
>   CC       /tmp/build/perf/libbpf.o
>   CC       /tmp/build/perf/util/parse-events.o
>   INSTALL  trace_plugins
> libbpf.c: In function ‘make_dir’:
> libbpf.c:1303:6: error: implicit declaration of function ‘mkdir’ [-Werror=implicit-function-declaration]
>   if (mkdir(path, 0700) && errno != EEXIST)
>       ^~~~~
> libbpf.c:1303:2: error: nested extern declaration of ‘mkdir’ [-Werror=nested-externs]
>   if (mkdir(path, 0700) && errno != EEXIST)
>   ^~
> cc1: all warnings being treated as errors
> mv: cannot stat '/tmp/build/perf/.libbpf.o.tmp': No such file or directory
> /home/acme/git/linux/tools/build/Makefile.build:101: recipe for target '/tmp/build/perf/libbpf.o' failed
> 
> 
> And strdup() is not checked for failure, I'm fixing those,
> 
> +++ b/tools/lib/bpf/libbpf.c
> @@ -36,6 +36,8 @@
>  #include <linux/magic.h>
>  #include <linux/list.h>
>  #include <linux/limits.h>
> +#include <sys/stat.h>
> +#include <sys/types.h>
>  #include <sys/vfs.h>

This as well:

@@ -1338,7 +1343,7 @@ int bpf_program__pin(struct bpf_program *prog,
const char *path)
                len = snprintf(buf, PATH_MAX, "%s/%d", path, i);
                if (len < 0)
                        return -EINVAL;
-               else if (len > PATH_MAX)
+               else if (len >= PATH_MAX)
                        return -ENAMETOOLONG;


See 'man snprintf', return value:

---
Thus, a return value of size or more means that the output was
truncated.
---
