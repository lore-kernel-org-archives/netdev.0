From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCHv3 perf/core 6/7] samples/bpf: Remove perf_event_open()
 declaration
Date: Fri, 9 Dec 2016 11:59:54 -0300
Message-ID: <20161209145954.GL8257@kernel.org>
References: <20161209024620.31660-1-joe@ovn.org>
 <20161209024620.31660-7-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, wangnan0@huawei.com, ast@fb.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
To: Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161209024620.31660-7-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Thu, Dec 08, 2016 at 06:46:19PM -0800, Joe Stringer escreveu:
> This declaration was made in samples/bpf/libbpf.c for convenience, but
> there's already one in tools/perf/perf-sys.h. Reuse that one.
> 
> Signed-off-by: Joe Stringer <joe@ovn.org>
> ---
> v3: First post.
> ---
>  samples/bpf/Makefile            | 3 ++-
>  samples/bpf/bpf_load.c          | 3 ++-
>  samples/bpf/libbpf.c            | 7 -------
>  samples/bpf/libbpf.h            | 3 ---
>  samples/bpf/sampleip_user.c     | 3 ++-
>  samples/bpf/trace_event_user.c  | 9 +++++----
>  samples/bpf/trace_output_user.c | 3 ++-
>  samples/bpf/tracex6_user.c      | 3 ++-
>  8 files changed, 15 insertions(+), 19 deletions(-)
> 
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index c8f7ed37b2de..0adc47e67e65 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -92,7 +92,8 @@ always += test_current_task_under_cgroup_kern.o
>  always += trace_event_kern.o
>  always += sampleip_kern.o
>  
> -HOSTCFLAGS += -I$(objtree)/usr/include -I$(objtree)/tools/lib/
> +HOSTCFLAGS += -I$(objtree)/usr/include -I$(objtree)/tools/lib/ \
> +	      -I$(objtree)/tools/include -I$(objtree)/tools/perf

Switching these to $(srctree) as well, to support building it like:

  make -j4 O=../build/v4.9.0-rc8+ samples/bpf/

>  
>  HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
>  HOSTLOADLIBES_fds_example += -lelf
> diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
> index f8e3c58a0897..d683bd278171 100644
> --- a/samples/bpf/bpf_load.c
> +++ b/samples/bpf/bpf_load.c
> @@ -19,6 +19,7 @@
>  #include <ctype.h>
>  #include "libbpf.h"
>  #include "bpf_load.h"
> +#include "perf-sys.h"
>  
>  #define DEBUGFS "/sys/kernel/debug/tracing/"
>  
> @@ -168,7 +169,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
>  	id = atoi(buf);
>  	attr.config = id;
>  
> -	efd = perf_event_open(&attr, -1/*pid*/, 0/*cpu*/, -1/*group_fd*/, 0);
> +	efd = sys_perf_event_open(&attr, -1/*pid*/, 0/*cpu*/, -1/*group_fd*/, 0);
>  	if (efd < 0) {
>  		printf("event %d fd %d err %s\n", id, efd, strerror(errno));
>  		return -1;
> diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
> index d9af876b4a2c..bee473a494f1 100644
> --- a/samples/bpf/libbpf.c
> +++ b/samples/bpf/libbpf.c
> @@ -34,10 +34,3 @@ int open_raw_sock(const char *name)
>  
>  	return sock;
>  }
> -
> -int perf_event_open(struct perf_event_attr *attr, int pid, int cpu,
> -		    int group_fd, unsigned long flags)
> -{
> -	return syscall(__NR_perf_event_open, attr, pid, cpu,
> -		       group_fd, flags);
> -}
> diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
> index cc815624aacf..09aedc320009 100644
> --- a/samples/bpf/libbpf.h
> +++ b/samples/bpf/libbpf.h
> @@ -188,7 +188,4 @@ struct bpf_insn;
>  /* create RAW socket and bind to interface 'name' */
>  int open_raw_sock(const char *name);
>  
> -struct perf_event_attr;
> -int perf_event_open(struct perf_event_attr *attr, int pid, int cpu,
> -		    int group_fd, unsigned long flags);
>  #endif
> diff --git a/samples/bpf/sampleip_user.c b/samples/bpf/sampleip_user.c
> index 09ab620b324c..476a11947180 100644
> --- a/samples/bpf/sampleip_user.c
> +++ b/samples/bpf/sampleip_user.c
> @@ -21,6 +21,7 @@
>  #include <sys/ioctl.h>
>  #include "libbpf.h"
>  #include "bpf_load.h"
> +#include "perf-sys.h"
>  
>  #define DEFAULT_FREQ	99
>  #define DEFAULT_SECS	5
> @@ -50,7 +51,7 @@ static int sampling_start(int *pmu_fd, int freq)
>  	};
>  
>  	for (i = 0; i < nr_cpus; i++) {
> -		pmu_fd[i] = perf_event_open(&pe_sample_attr, -1 /* pid */, i,
> +		pmu_fd[i] = sys_perf_event_open(&pe_sample_attr, -1 /* pid */, i,
>  					    -1 /* group_fd */, 0 /* flags */);
>  		if (pmu_fd[i] < 0) {
>  			fprintf(stderr, "ERROR: Initializing perf sampling\n");
> diff --git a/samples/bpf/trace_event_user.c b/samples/bpf/trace_event_user.c
> index de8fd0266d78..ccb0cba8324a 100644
> --- a/samples/bpf/trace_event_user.c
> +++ b/samples/bpf/trace_event_user.c
> @@ -20,6 +20,7 @@
>  #include <sys/resource.h>
>  #include "libbpf.h"
>  #include "bpf_load.h"
> +#include "perf-sys.h"
>  
>  #define SAMPLE_FREQ 50
>  
> @@ -126,9 +127,9 @@ static void test_perf_event_all_cpu(struct perf_event_attr *attr)
>  
>  	/* open perf_event on all cpus */
>  	for (i = 0; i < nr_cpus; i++) {
> -		pmu_fd[i] = perf_event_open(attr, -1, i, -1, 0);
> +		pmu_fd[i] = sys_perf_event_open(attr, -1, i, -1, 0);
>  		if (pmu_fd[i] < 0) {
> -			printf("perf_event_open failed\n");
> +			printf("sys_perf_event_open failed\n");
>  			goto all_cpu_err;
>  		}
>  		assert(ioctl(pmu_fd[i], PERF_EVENT_IOC_SET_BPF, prog_fd[0]) == 0);
> @@ -147,9 +148,9 @@ static void test_perf_event_task(struct perf_event_attr *attr)
>  	int pmu_fd;
>  
>  	/* open task bound event */
> -	pmu_fd = perf_event_open(attr, 0, -1, -1, 0);
> +	pmu_fd = sys_perf_event_open(attr, 0, -1, -1, 0);
>  	if (pmu_fd < 0) {
> -		printf("perf_event_open failed\n");
> +		printf("sys_perf_event_open failed\n");
>  		return;
>  	}
>  	assert(ioctl(pmu_fd, PERF_EVENT_IOC_SET_BPF, prog_fd[0]) == 0);
> diff --git a/samples/bpf/trace_output_user.c b/samples/bpf/trace_output_user.c
> index 9c38f7aa4515..64e692fd7d51 100644
> --- a/samples/bpf/trace_output_user.c
> +++ b/samples/bpf/trace_output_user.c
> @@ -21,6 +21,7 @@
>  #include <signal.h>
>  #include "libbpf.h"
>  #include "bpf_load.h"
> +#include "perf-sys.h"
>  
>  static int pmu_fd;
>  
> @@ -160,7 +161,7 @@ static void test_bpf_perf_event(void)
>  	};
>  	int key = 0;
>  
> -	pmu_fd = perf_event_open(&attr, -1/*pid*/, 0/*cpu*/, -1/*group_fd*/, 0);
> +	pmu_fd = sys_perf_event_open(&attr, -1/*pid*/, 0/*cpu*/, -1/*group_fd*/, 0);
>  
>  	assert(pmu_fd >= 0);
>  	assert(bpf_map_update_elem(map_fd[0], &key, &pmu_fd, BPF_ANY) == 0);
> diff --git a/samples/bpf/tracex6_user.c b/samples/bpf/tracex6_user.c
> index 7a3b4a4b19f3..1681cb7cd713 100644
> --- a/samples/bpf/tracex6_user.c
> +++ b/samples/bpf/tracex6_user.c
> @@ -10,6 +10,7 @@
>  #include <linux/bpf.h>
>  #include "libbpf.h"
>  #include "bpf_load.h"
> +#include "perf-sys.h"
>  
>  #define SAMPLE_PERIOD  0x7fffffffffffffffULL
>  
> @@ -32,7 +33,7 @@ static void test_bpf_perf_event(void)
>  	};
>  
>  	for (i = 0; i < nr_cpus; i++) {
> -		pmu_fd[i] = perf_event_open(&attr_insn_pmu, -1/*pid*/, i/*cpu*/, -1/*group_fd*/, 0);
> +		pmu_fd[i] = sys_perf_event_open(&attr_insn_pmu, -1/*pid*/, i/*cpu*/, -1/*group_fd*/, 0);
>  		if (pmu_fd[i] < 0) {
>  			printf("event syscall failed\n");
>  			goto exit;
> -- 
> 2.10.2
