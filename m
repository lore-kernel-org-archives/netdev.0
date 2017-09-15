From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: selftests/bpf doesn't compile
Date: Fri, 15 Sep 2017 11:44:36 -0600
Message-ID: <e9c0f09e-3c8d-961c-3f9e-aaa3a28a42ce@osg.samsung.com>
References: <20170908111923.27434-1-thomas@m3y3r.de>
 <20170908230155.esge2mctk5d5g7gb@ast-mbp> <59B32231.9090406@iogearbox.net>
 <ed20875b-7a01-fbc8-e8d1-3929ba35c8ac@kernel.org>
 <295553a4-aadc-e5d1-229e-22d1966bc9f5@kernel.org>
 <20170915160253.q3x5j7hfkxxh2g6w@ast-mbp>
 <e07dabee-6c9c-7842-65b0-990a2ed1a2e9@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Meyer <thomas@m3y3r.de>, linux-kernel@vger.kernel.org,
        linux-kselftest@vger.kernel.org,
        Networking <netdev@vger.kernel.org>,
        Shuah Khan <shuahkh@osg.samsung.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Shuah Khan <shuah@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e07dabee-6c9c-7842-65b0-990a2ed1a2e9@osg.samsung.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/15/2017 11:00 AM, Shuah Khan wrote:
> On 09/15/2017 10:02 AM, Alexei Starovoitov wrote:
>> On Thu, Sep 14, 2017 at 09:33:48AM -0600, Shuah Khan wrote:
>>> Hi Alexei and Daniel,
>>>
>>> bpf test depends on clang and fails to compile when
>>>
>>> ------------------------------------------------------
>>> make -C tools/testing/selftests/bpf run_tests
>>>
>>>
>>> make: clang: Command not found
>>> Makefile:39: recipe for target '.linux-kselftest/tools/testing/selftests/bpf/test_pkt_access.o' failed
>>> make: *** [./linux-kselftest/tools/testing/selftests/bpf/test_pkt_access.o] Error 127
>>> make: Leaving directory '.linux-kselftest/tools/testing/selftests/bpf'
>>>
>>> With "make TARGETS=bpf kselftest" it fails earlier:
>>>
>>>
>>> make[3]: Entering directory './linux-kselftest/tools/lib/bpf'
>>> Makefile:40: tools/scripts/Makefile.arch: No such file or directory
>>> Makefile:84: tools/build/Makefile.feature: No such file or directory
>>> Makefile:143: tools/build/Makefile.include: No such file or directory
>>> make[3]: *** No rule to make target 'tools/build/Makefile.include'.  Stop.
>>> make[3]: Leaving directory '.linux-kselftest/tools/lib/bpf'
>>> Makefile:34: recipe for target './linux-kselftest/tools/testing/selftests/bpf/libbpf.a' failed
>>> make[2]: *** [./linux-kselftest/tools/testing/selftests/bpf/libbpf.a] Error 2
>>> make[2]: Leaving directory './linux-kselftest/tools/testing/selftests/bpf'
>>> Makefile:69: recipe for target 'all' failed
>>> make[1]: *** [all] Error 2
>>> Makefile:1190: recipe for target 'kselftest' failed
>>> make: *** [kselftest] Error 2
>>>
>>> --------------------------------------------------------------
>>>
>>> Is bpf test intended to be run in kselftest run? The clang dependency might
>>> not be met on majority of the systems. Is this a hard dependency??
>>
>> It is a hard dependency and clang should be present on majority of the systems.
>> More details are in samples/bpf/README.rst
>> which was written long ago. Nowadays apt-get/yum will install clang
>> with bpf support builtin.
> 
> Thanks for the clarification.
> 
>>
>>> Would it make sense to create a special target for bpf test? We do have a few
>>> tests that do that now. 
>>>
>>> TARGETS_HOTPLUG = cpu-hotplug
>>> TARGETS_HOTPLUG += memory-hotplug
>>>
>>> I could add a special target for bpf TARGET_BPF perhaps and exclude it from
>>> the run_test> 
>> I'm not sure what was the motivation to exclude hotplug from default testing,
> 
> These are considered a bit more disruptive and were excluded a while
> back. These take cpus and memory on and off-line. Also require
> root access. So even if they are included in the regular run, these
> won't run.
> 
>> since I think it diminishes the value of selftests overall.
> 
> I agree. We do have some timer tests that are destructive/stress that
> et run using a special target. It is the idea that if somebody wants
> to test all them, there is a way to do that.
> 
> In any case, I didn't think bpf falls into this category of tests that
> belong in the destructive category. I am looking to understand the failures
> and your take on those.
> 
>> Not running all tests all the time risks breaking them
> It is balance of providing a choice to users if they don't want to
> run destructive tests. For example, suspend test which requires root
> access. So the idea is for users to run these by choice as opposed
> to running them in the normal run and cause disruption.
> 
>> selftest makefile refactoring broke selftests/bpf in the past,
> 
> Yeah. We have had some fallout from the KBUILD_OUTPUT work that didn't
> take all the use-cases into account and tests that require custom
> builds such as the bpf tests. Using common build infrastructure doesn't
> work for all tests.
> 
> Looks like there are other patches that went in later with lcap work.
> 
>> so I strongly suggest to install clang and make sure the tests are passing
>> on the test servers 
> 
> You will have to request kernelci, stable, and It is a choice to be made by
> kernelci/zero-day folks.
> 
> otherwise we'd need to move selftests/bpf out of
>> selftests to avoid further headaches for us when selftests infra keeps
>> changing.
>>
> 
> Let's not go to extreme options. :) I am merely looking for more information
> and trying to understand the dependencies for this test.
> 
> Let's look for a constructive option to fix the build failures I am seeing.
> 
> The first failure due to clang dependency is not a problem.

Let me clarify that. People interested in running bpf test will have to
install clang. In that sense installing clang will solve that issue.

The hard dependency on clang does make it difficult for developers to
ensure they didn't break bpf when they make changes to the kselftest
common infrastructure.

The second one
> in the case of "make kselftest" is the one that requires some work when bpf
> make is run from the main Makefile. A lots of users run tests using the
> kselftest target from the mail Makefile. hence I would like to get this
> working, so it would be easier to run this test on test servers.
> 

Even if this is fixed, unless users choose to install clang, bpf will always
fail run without clang. So clang dependency is an issue for bpf test coverage
in general. But that is your choice as to whether you want to increase the
scope of regression test coverage for bpf or not.

thanks,
-- Shuah
