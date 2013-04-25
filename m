From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 1/3 RFC v2] selftests: introduce testing abstractions
Date: Thu, 25 Apr 2013 20:19:08 +0200
Message-ID: <5179739C.9080005@redhat.com>
References: <1366887900-24769-1-git-send-email-alex.mihai.c@gmail.com> <1366887900-24769-2-git-send-email-alex.mihai.c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, davem@davemloft.net, willemb@google.com,
	ebiederm@xmission.com, gorcunov@openvz.org, palewis@adobe.com,
	edumazet@google.com, Daniel Baluta <dbaluta@ixiacom.com>
To: Alexandru Copot <alex.mihai.c@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366887900-24769-2-git-send-email-alex.mihai.c@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/25/2013 01:04 PM, Alexandru Copot wrote:
> Signed-of-by Alexandru Copot <alex.mihai.c@gmail.com>
> Cc: Daniel Baluta <dbaluta@ixiacom.com>
> ---
>   tools/testing/selftests/Makefile        |  3 +-
>   tools/testing/selftests/lib/Makefile    | 14 +++++++
>   tools/testing/selftests/lib/selftests.c | 57 ++++++++++++++++++++++++++++
>   tools/testing/selftests/lib/selftests.h | 67 +++++++++++++++++++++++++++++++++
>   4 files changed, 140 insertions(+), 1 deletion(-)
>   create mode 100644 tools/testing/selftests/lib/Makefile
>   create mode 100644 tools/testing/selftests/lib/selftests.c
>   create mode 100644 tools/testing/selftests/lib/selftests.h
>
> diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
> index a480593..e0fccd9 100644
> --- a/tools/testing/selftests/Makefile
> +++ b/tools/testing/selftests/Makefile
> @@ -1,4 +1,5 @@
> -TARGETS = breakpoints
> +TARGETS = lib
> +TARGETS += breakpoints
>   TARGETS += kcmp
>   TARGETS += mqueue
>   TARGETS += vm
> diff --git a/tools/testing/selftests/lib/Makefile b/tools/testing/selftests/lib/Makefile
> new file mode 100644
> index 0000000..9c81d0c
> --- /dev/null
> +++ b/tools/testing/selftests/lib/Makefile
> @@ -0,0 +1,14 @@
> +
> +CFLAGS = -Wall -O2 -c -g
> +
> +selftests.a: selftests.o
> +	ar qc $@ $^
> +
> +%.c: %.h
> +
> +%.o: %.c
> +	$(CC) $(CFLAGS) -o $@ $^
> +
> +clean:
> +	rm -rf *.o *.a
> +
> diff --git a/tools/testing/selftests/lib/selftests.c b/tools/testing/selftests/lib/selftests.c
> new file mode 100644
> index 0000000..1a65785
> --- /dev/null
> +++ b/tools/testing/selftests/lib/selftests.c
> @@ -0,0 +1,57 @@
> +#include <stdio.h>
> +#include <stdarg.h>
> +
> +#include "selftests.h"
> +
> +test_result_t __assert(int expr, const char *filename, int line, const char *fmt, ...)
> +{

Usually I associate sth named assert() that it does an ungraceful exit. Maybe __test() or __check()?

> +	va_list vl;
> +	const char *m;
> +	char msg[BUFSIZ];
> +
> +	if (expr)
> +		return TEST_PASS;
> +
> +	fprintf(stderr, "\n(%s:%d) ", filename, line);
> +
> +	va_start(vl, fmt);
> +	m = va_arg(vl, char *);
> +	if (!m)
> +		m = fmt;
> +	else
> +		fprintf(stderr, "%s ", fmt);
> +
> +	vsnprintf(msg, sizeof msg, m, vl);

Nitpick: sizeof(msg)

> +	va_end(vl);
> +
> +	fprintf(stderr, "%s\n", msg);

Not sure what exactly you are trying to accomplish here in this function?
Why don't you use vfprintf() and leave this hackery aside?

va_list vl;

va_start(vl, fmt);
fprintf(stderr, "(%s:%d) ", filename, line);
vfprintf(stderr, fmt, vl);
va_end(vl);

> +	return TEST_FAIL;
> +}
> +
> +test_result_t run_all_tests(struct generic_test *test, void *param)
> +{
> +	int i;
> +	char *ptr = test->testcases;
> +	test_result_t rc = TEST_PASS;

Here you don't need to inint rc, since you overwrite immediately.

> +	rc = test->prepare ? test->prepare(param) : 0;

Also replace 0 with whatever you have defined for TEST_PASS or TEST_FAIL,
otherwise misleading.

> +	if (rc == TEST_FAIL)
> +		return rc;
> +
> +	fprintf(stderr, "Testing: %s ", test->name);
> +	for (i = 0; i < test->testcase_count; i++) {
> +

No whitespace here.

> +		rc |= test->run(ptr);
> +		ptr += test->testcase_size;
> +		
> +		if (rc == TEST_FAIL && test->abort_on_fail) {
> +			fprintf(stderr, "Test aborted\n");
> +			break;
> +		}
> +	}
> +
> +	fprintf(stderr, "\t\t%s\n", rc ? "[FAIL]" : "[PASS]");
> +	return rc;
> +}
> +
> diff --git a/tools/testing/selftests/lib/selftests.h b/tools/testing/selftests/lib/selftests.h
> new file mode 100644
> index 0000000..6210199
> --- /dev/null
> +++ b/tools/testing/selftests/lib/selftests.h
> @@ -0,0 +1,67 @@
> +#ifndef SELFTESTS_H
> +#define SELFTESTS_H
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <errno.h>
> +
> +typedef enum test_result {
> +	TEST_PASS = 0,
> +	TEST_FAIL,
> +} test_result_t;

I have no strong opinion here, but do we need to make this as an enum and then do
bit-operations on it?

> +test_result_t __assert(int expr, const char *filename, int line, const char *fmt, ...);

Nitpick:

If would be nice if you move run_all_tests() either here below this one or the other way
around, so that function decls are not distributed over the file, but together.

> +#define abort(cond) do {							\
> +	if (!(cond)) {								\
> +		fprintf(stderr, "%s:%d %s\n", __FILE__, __LINE__, #cond);	\
> +		perror("");							\

perror() could be removed from here and put into fprintf() by using f.e. %s + strerror(errno).

> +		exit(EXIT_FAILURE);						\
> +	}									\
> +} while (0)
> +
> +#define pass_if(expr, label, ret)				\
> +	do {                                                    \
> +		if (expr) {					\
> +			ret = TEST_PASS;			\
> +			goto label;				\
> +		}						\
> +	} while (0)

In cases where you make use of this macro, it's always like ...

<function>
{
	pass_if(<cond>, out, ret);
[...]
out:
	return ret;
}

Not sure if this simplifies or rather obfuscates things. Maybe other people
like it, not sure ...

> +/* @expr:   a boolean expression
> + * @label:  jump here to free resources if it fails
> + * @ret:    a test_result_t variable that will hold the result of the test
> + *          This can be later returned from the test function.
> + */
> +#define check(expr, label, ret, ...)					     \
> +	do {                                                                 \
> +		ret = __assert(expr, __FILE__, __LINE__,       		     \
> +			       "Assertion '" #expr "' failed", __VA_ARGS__); \
> +		if (!(expr)) {						     \
> +			perror("");					     \
> +			goto label;                                          \
> +		}							     \
> +	} while (0)

Ditto.

> +struct generic_test {
> +	const char *name;
> +	void *private;
> +
> +

Why do you have two blank lines here?

> +	void *testcases;

It seems you like having void* pointers, right? This is very unintuitive here (and
weird that you iterate with a char* pointer over it in function run_all_tests())
and at least needs some comments. Otherwise people will have to look into your
example to get to know what you mean.

Also, what is the difference between testcases and private? I have not seen that
you use private anywhere.

> +	int testcase_size;

Nitpick (but that depends if you keep void*): size_t len;

> +	int testcase_count;

Nitpick (ditto): unsigned int num_cases;

> +	/* Ends all tests if one fails */
> +	int abort_on_fail;

bool abort_on_fail;

> +	test_result_t (*prepare)(void *);
> +	test_result_t (*run)(void *);
> +	test_result_t (*cleanup)(void *);
> +};
> +
> +test_result_t run_all_tests(struct generic_test *test, void *param);
> +
> +#endif
> +
> +

Also no blank lines at the end of a file!

Ok, for now I leave the other patches aside, maybe you have some comments to the
review, a new version, or wait a while for others to give feedback as well.

Thanks and cheers,

Daniel
