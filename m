From: Helge Deller <deller@gmx.de>
Subject: Re: rhashtable - rhashtable_insert_fast failed
Date: Sat, 4 Jun 2016 20:05:48 +0200
Message-ID: <5753187C.7070703@gmx.de>
References: <5751E702.5040909@gmx.de> <20160604073527.GE29740@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "tgraf@suug.ch" <tgraf@suug.ch>,
	Mikulas Patocka <mpatocka@redhat.com>
To: Phil Sutter <phil@nwl.cc>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20160604073527.GE29740@orbyte.nwl.cc>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Phil,

On 04.06.2016 09:35, Phil Sutter wrote:
> [Cc'ing other interested parties, therefore full-quoting.]
> On Fri, Jun 03, 2016 at 10:22:26PM +0200, Helge Deller wrote:
>> I'm testing 4.7.0-rc1-64bit on a parisc/hppa machine and get
>> those message with CONFIG_TEST_RHASHTABLE=y.
>>
>> Is this expected/normal ?
> 
> No, this shouldn't happen. Can you possibly bisect the issue?

I did some more testing.


>> [   11.004021] Running rhashtable test nelem=8, max_size=0, shrinking=0
>> [   11.060013] Test 00:
>> [   11.181391]   Adding 50000 keys
>> [   11.299533] Info: encountered resize
>> [   11.344499] Info: encountered resize
>> [   11.392971] Info: encountered resize
>> [   11.447632]   Traversal complete: counted=50628, nelems=50000, entries=50000, table-jumps=3
>> [   11.556024] Test failed: Total count mismatch ^^^

I still see this randomly on my boxes.
Still need to check further. 

>> [   11.647150]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
>> [   11.760022]   Deleting 50000 keys
>> [   11.822941]   Duration of test: 596000000 ns
>> [   11.876057] Test 01:
>> [   11.919907]   Adding 50000 keys
>> [   12.024027] Info: encountered resize
>> [   12.024767] Info: encountered resize
>> [   12.072981] Info: encountered resize
>> [   12.169265]   Traversal complete: counted=53763, nelems=50000, entries=50000, table-jumps=3
>> [   12.172021] Test failed: Total count mismatch ^^^
>> [   12.377004]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
>> [   12.380022]   Deleting 50000 keys
>> [   12.552900]   Duration of test: 596000000 ns
>> [   12.556069] Test 02:
>> [   12.650017]   Adding 50000 keys
>> [   12.746381] Info: encountered resize
>> [   12.792486] Info: encountered resize
>> [   12.840977] Info: encountered resize
>> [   12.894604]   Traversal complete: counted=52831, nelems=50000, entries=50000, table-jumps=3
>> [   13.004025] Test failed: Total count mismatch ^^^
>> [   13.094046]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
>> [   13.204022]   Deleting 50000 keys
>> [   13.269555]   Duration of test: 576000000 ns
>> [   13.324062] Test 03:
>> [   13.366586]   Adding 50000 keys
>> [   13.466624] Info: encountered resize
>> [   13.468255] Info: encountered resize
>> [   13.516485] Info: encountered resize
>> [   13.564977] Info: encountered resize
>> [   13.662159]   Traversal complete: counted=52381, nelems=50000, entries=50000, table-jumps=4
>> [   13.664022] Test failed: Total count mismatch ^^^
>> [   13.870009]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
>> [   13.876015]   Deleting 50000 keys
>> [   14.045912]   Duration of test: 640000000 ns
>> [   14.048065] Average test time: 602000000
>> [   14.104017] Testing concurrent rhashtable access from 10 threads
>> [   14.537134]   thread[6]: rhashtable_insert_fast failed
>> [   14.540722]   thread[5]: rhashtable_insert_fast failed
>> [   14.540747]   thread[1]: rhashtable_insert_fast failed
>> [   14.540757]   thread[3]: rhashtable_insert_fast failed
>> [   14.540767]   thread[0]: rhashtable_insert_fast failed
>> [   14.540862]   thread[7]: rhashtable_insert_fast failed
>> [   14.540873]   thread[9]: rhashtable_insert_fast failed
>> [   14.540874]   thread[2]: rhashtable_insert_fast failed
>> [   14.540874]   thread[4]: rhashtable_insert_fast failed
>> [   14.676061] Test failed: thread 0 returned: -12
>> [   14.676102] Test failed: thread 1 returned: -12
>> [   14.676120]   thread[8]: rhashtable_insert_fast failed
>> [   14.676153] Test failed: thread 2 returned: -12
>> [   14.676176] Test failed: thread 3 returned: -12
>> [   14.676199] Test failed: thread 4 returned: -12
>> [   14.676224] Test failed: thread 5 returned: -12
>> [   15.516892] Test failed: thread 6 returned: -12
>> [   15.644271] Test failed: thread 7 returned: -12
>> [   15.708319] Test failed: thread 8 returned: -12
>> [   15.772074] Test failed: thread 9 returned: -12
>> [   15.832013] Started 10 threads, 10 failed

Those -12 error messages seem to indicate, that there is memory
pressure on my box (ENOMEM), right?
That might be true for parisc right now as reported by Mikulas at
 http://www.spinics.net/lists/linux-parisc/msg07066.html
and fixed by this patch:
 http://marc.info/?l=linux-mm&m=146468933302010&w=2
which I applied then.

Additionally I enabled the enomem_retry kernel option.

With those changes I get:
[   71.752666] Testing concurrent rhashtable access from 10 threads
[   72.548724]  8812 insertions retried after -ENOMEM
[   72.611804]  8799 insertions retried after -ENOMEM
[   72.674785]  8906 insertions retried after -ENOMEM
[   72.737836]  8895 insertions retried after -ENOMEM
[   72.800804]  9337 insertions retried after -ENOMEM
[   72.863843]  11122 insertions retried after -ENOMEM
[   72.927993]  11163 insertions retried after -ENOMEM
[   72.992219]  11121 insertions retried after -ENOMEM
[   73.056331]  11011 insertions retried after -ENOMEM
[   73.120492]  11121 insertions retried after -ENOMEM
[   73.621555]   thread[4]: 8799 insertions retried due to memory pressure
[   73.709060]   thread[5]: 8906 insertions retried due to memory pressure
[   73.804561]   thread[3]: 8895 insertions retried due to memory pressure
[   73.894631]   thread[1]: 9337 insertions retried due to memory pressure
[   73.988483]   thread[0]: 11122 insertions retried due to memory pressure
[   74.087575]   thread[7]: 11163 insertions retried due to memory pressure
[   74.180283]   thread[6]: 11121 insertions retried due to memory pressure
[   74.276768]   thread[2]: 11121 insertions retried due to memory pressure
[   74.367538]   thread[9]: 11011 insertions retried due to memory pressure
[   74.472908]   thread[8]: 8812 insertions retried due to memory pressure
[   79.281516] Started 10 threads, 0 failed

I'll try to investigate further on this.

Helge 
