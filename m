From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: Re: [PATCH 1/3 RFC v2] selftests: introduce testing abstractions
Date: Fri, 26 Apr 2013 11:39:19 +0300
Message-ID: <CAHG7+CDn4ELhmigo3j4R4qg29oO-NwdCR+=WGk7PmpVL2WTtaA@mail.gmail.com>
References: <1366887900-24769-1-git-send-email-alex.mihai.c@gmail.com>
	<1366887900-24769-2-git-send-email-alex.mihai.c@gmail.com>
	<5179739C.9080005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, davem@davemloft.net, willemb@google.com,
	ebiederm@xmission.com, gorcunov@openvz.org, palewis@adobe.com,
	edumazet@google.com, Daniel Baluta <dbaluta@ixiacom.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5179739C.9080005@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 25, 2013 at 9:19 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> Usually I associate sth named assert() that it does an ungraceful exit.
> Maybe __test() or __check()?

This looks like a good idea, will do.

>> +       va_list vl;
>> +       const char *m;
>> +       char msg[BUFSIZ];
>> +
>> +       if (expr)
>> +               return TEST_PASS;
>> +
>> +       fprintf(stderr, "\n(%s:%d) ", filename, line);
>> +
>> +       va_start(vl, fmt);
>> +       m = va_arg(vl, char *);
>> +       if (!m)
>> +               m = fmt;
>> +       else
>> +               fprintf(stderr, "%s ", fmt);
>> +
>> +       vsnprintf(msg, sizeof msg, m, vl);
>
>
> Nitpick: sizeof(msg)

sizeof is actually an operator. I could change it especially to
keep an uniform coding style with the rest of the kernel and tools.

>
>> +       va_end(vl);
>> +
>> +       fprintf(stderr, "%s\n", msg);
>
>
> Not sure what exactly you are trying to accomplish here in this function?
> Why don't you use vfprintf() and leave this hackery aside?
>
> va_list vl;
>
> va_start(vl, fmt);
> fprintf(stderr, "(%s:%d) ", filename, line);
> vfprintf(stderr, fmt, vl);
> va_end(vl);
>

Here I am trying to format both using the fmt string and the one that
the user might write as the next argument. It's not really safe, but
this way we can print whatever data is needed to diagnose a failure.

Example: check(r == 0, out_label, ret, "option %d", 5);

But I think you are right, I will keep it simple for the moment.

>> +typedef enum test_result {
>> +       TEST_PASS = 0,
>> +       TEST_FAIL,
>> +} test_result_t;
>
>
> I have no strong opinion here, but do we need to make this as an enum and
> then do bit-operations on it?

I like enums because of type safety, but I will change these to defines.

>> +
>> +#define pass_if(expr, label, ret)                              \
>> +       do {                                                    \
>> +               if (expr) {                                     \
>> +                       ret = TEST_PASS;                        \
>> +                       goto label;                             \
>> +               }                                               \
>> +       } while (0)
>
>
> In cases where you make use of this macro, it's always like ...
>
> <function>
> {
>         pass_if(<cond>, out, ret);
> [...]
> out:
>         return ret;
> }
>
> Not sure if this simplifies or rather obfuscates things. Maybe other people
> like it, not sure ...

This looks like the cleanest solution to me. We have found some other
implementations
which used weird things like setjmp/longjmp. We are open to any
suggestions on this.

>
>> +struct generic_test {
>> +       const char *name;
>> +       void *private;
>> +
>> +
>
>
> Why do you have two blank lines here?
>

Correct, will remove.

>> +       void *testcases;
>
>
> It seems you like having void* pointers, right? This is very unintuitive
> here (and weird that you iterate with a char* pointer over it in function
> run_all_tests())
> and at least needs some comments. Otherwise people will have to look into
> your example to get to know what you mean.

Having void pointers is simpler because it doesn't force you to write casts. It
is also generic. I iterate with char* because I can't do it with a void*.
Yes, you are right about the comments.

> Also, what is the difference between testcases and private? I have not seen
> that you use private anywhere.

The private field is mostly for future use, will remove it for now until
we find some real use case.

>> +       int testcase_size;
>
>
> Nitpick (but that depends if you keep void*): size_t len;
>
>> +       int testcase_count;
>
>
> Nitpick (ditto): unsigned int num_cases;
>
>
>> +       /* Ends all tests if one fails */
>> +       int abort_on_fail;
>
>
> bool abort_on_fail;
>
> Also no blank lines at the end of a file!

I agree with all of these.

> Ok, for now I leave the other patches aside, maybe you have some comments to
> the review, a new version, or wait a while for others to give feedback as well.
>
> Thanks and cheers,
>
> Daniel

Thanks for being so thorough!

Alex
