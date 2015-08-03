From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 4/6] test_bpf: add module parameters to filter the tests
 to run.
Date: Mon, 03 Aug 2015 17:58:08 +0200
Message-ID: <55BF8F90.5030001@iogearbox.net>
References: <1438610528-14245-1-git-send-email-nschichan@freebox.fr> <1438610528-14245-5-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Nicolas Schichan <nschichan@freebox.fr>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438610528-14245-5-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2015 04:02 PM, Nicolas Schichan wrote:
> When developping on the interpreter or a particular JIT, it can be
> insteresting to restrict the test list to a specific test or a

s/insteresting/interesting/

> particular range of tests.
>
> This patch adds the following module parameters to the test_bpf module:
>
> * test_name=<string>: only the specified named test will be run.
>
> * test_id=<number>: only the test with the specified id will be run
>    (see the output of test_pbf without parameters to get the test id).

s/test_pbf/test_bpf/

> * test_range=<number>,<number>: only the tests with IDs in the
>    specified id range are run (see the output of test_pbf without

s/test_pbf/test_bpf/

>    parameters to get the test ids).
>
> Any invalid range, test id or test name will result in -EINVAL being
> returned and no tests being run.
>
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>

Seems very useful for the test suite, thanks.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

> ---
>   lib/test_bpf.c | 73 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 73 insertions(+)
>
> diff --git a/lib/test_bpf.c b/lib/test_bpf.c
> index f5606fb..abd0507 100644
> --- a/lib/test_bpf.c
> +++ b/lib/test_bpf.c
> @@ -4870,10 +4870,72 @@ static int run_one(const struct bpf_prog *fp, struct bpf_test *test)
>   	return err_cnt;
>   }
>
> +static char test_name[64];
> +module_param_string(test_name, test_name, sizeof(test_name), 0);
> +
> +static int test_id = -1;
> +module_param(test_id, int, 0);
> +
> +static int test_range[2] = { -1, -1 };
> +module_param_array(test_range, int, NULL, 0);
> +
> +static __init int find_test_index(const char *test_name)
> +{
> +	int i;
> +
> +	for (i = 0; i < ARRAY_SIZE(tests); i++) {
> +		if (!strcmp(tests[i].descr, test_name))
> +			return i;
> +	}
> +	return -1;
> +}
> +
>   static __init int prepare_bpf_tests(void)
>   {
>   	int i;
>
> +	if (test_id >= 0) {
> +		/*
> +		 * if a test_id was specified, use test_range to
> +		 * conver only that test.

s/conver/cover/

> +		 */
> +		if (test_id >= ARRAY_SIZE(tests)) {
> +			pr_err("test_bpf: invalid test_id specified.\n");
> +			return -EINVAL;
> +		}
[...]
> @@ -4893,6 +4955,14 @@ static __init void destroy_bpf_tests(void)
>   	}
>   }
>
> +static bool exclude_test(int test_id)
> +{
> +	if (test_range[0] >= 0 &&
> +	    (test_id < test_range[0] || test_id > test_range[1]))
> +		return true;
> +	return false;

Minor nit: could directly return it, f.e.:

	return test_range[0] >= 0 && (test_id < test_range[0] ||
                                       test_id > test_range[1]);

Btw, for the range test in prepare_bpf_tests(), you could also reject
a negative lower bound index right there.
