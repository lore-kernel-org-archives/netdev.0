From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 1/3 net-next RFC] selftest: add abstractions for net selftests
Date: Tue, 09 Apr 2013 13:13:37 +0200
Message-ID: <5163F7E1.8040208@redhat.com>
References: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com> <1365503461-26309-2-git-send-email-alex.mihai.c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, willemb@google.com,
	edumazet@google.com, Daniel Baluta <dbaluta@ixiacom.com>
To: Alexandru Copot <alex.mihai.c@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14608 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752530Ab3DILNp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 07:13:45 -0400
In-Reply-To: <1365503461-26309-2-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2013 12:30 PM, Alexandru Copot wrote:
> Signed-of by Alexandru Copot <alex.mihai.c@gmail.com>
> Cc: Daniel Baluta <dbaluta@ixiacom.com>
> ---
>   tools/testing/selftests/net/selftests.c | 30 +++++++++++++++++++++++
>   tools/testing/selftests/net/selftests.h | 42 +++++++++++++++++++++++++++++++++
>   2 files changed, 72 insertions(+)
>   create mode 100644 tools/testing/selftests/net/selftests.c
>   create mode 100644 tools/testing/selftests/net/selftests.h
>
> diff --git a/tools/testing/selftests/net/selftests.c b/tools/testing/selftests/net/selftests.c
> new file mode 100644
> index 0000000..cd6e427
> --- /dev/null
> +++ b/tools/testing/selftests/net/selftests.c
> @@ -0,0 +1,30 @@
> +#include <stdio.h>
> +
> +#include "selftests.h"
> +
> +int run_all_tests(struct generic_test *test, void *param)
> +{
> +	int i;
> +	int rc, allrc;
> +	char *ptr;
> +
> +	rc = test->prepare ? test->prepare(param) : 0;
> +	if (rc)
> +		return rc;
> +
> +	allrc = 0;

Nitpick: this could already have been initialized above.

> +	printf("Testing: %s ", test->name);
> +	ptr = test->testcases;

ditto

> +	for (i = 0; i < test->testcase_count; i++) {
> +		rc = test->run(ptr);
> +		allrc |= rc;
> +
> +		if (test->abort_on_fail && rc) {
> +			printf("Testcase %d failed, aborting\n", i);
> +		}

I think here you wanted to abort but didn't?

> +
> +		ptr += test->testcase_size;
> +	}
> +	printf("\t\t%s\n", allrc ? "[FAIL]" : "[PASS]");
> +	return allrc;
> +}
> diff --git a/tools/testing/selftests/net/selftests.h b/tools/testing/selftests/net/selftests.h
> new file mode 100644
> index 0000000..e289f03
> --- /dev/null
> +++ b/tools/testing/selftests/net/selftests.h
> @@ -0,0 +1,42 @@
> +#ifndef SELFTESTS_H
> +#define SELFTESTS_H
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <errno.h>
> +
> +#define ASSERT(cond) do {								\
> +	if (!(cond))     {								\
> +			fprintf(stderr, "%s:%d %s\n", __FILE__, __LINE__, #cond);	\
> +			perror("");							\
> +			exit(EXIT_FAILURE);						\
> +		}									\
> +} while (0)
> +
> +#define CHECK(cond,fmt,...)			        \
> +	do {						\
> +		if (!(cond)) {                          \
> +			fprintf(stderr, "(%s, %d): " fmt,	\
> +					__FILE__, __LINE__, ##__VA_ARGS__); \
> +			perror("");              	\
> +			return 1;			\
> +		}					\
> +	} while (0)

Isn't it a bit error-prone if in the middle of somewhere this check fails
and the function suddenly returns 1?

What if this is called from a function that was declared as void or to
return a pointer to a struct etc.?

> +struct generic_test {
> +	const char *name;
> +	void *testcases;
> +	int testcase_size;
> +	int testcase_count;
> +
> +	int abort_on_fail;
> +
> +	int (*prepare)(void *);
> +	int (*run)(void *);
> +	int (*cleanup)(void *);
> +};
> +
> +int run_all_tests(struct generic_test *test, void *param);
> +
> +#endif
> +
>

Nitpick: here's an extra newline at the end of the file.
