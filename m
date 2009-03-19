From: Dave Boutcher <daveboutcher@gmail.com>
Subject: Re: IGMP Join dropping multicast packets
Date: Wed, 18 Mar 2009 20:48:58 -0500
Message-ID: <91bdcedb0903181848s14289e9di417b8aef04d6f707@mail.gmail.com>
References: <91bdcedb0903141316j2dbf4160wb348a5a9e3bde8ad@mail.gmail.com>
	<49BC69D5.5000002@cosmosbay.com>
	<91bdcedb0903151904x1066ac24h63557b588e7c4967@mail.gmail.com>
	<49BEA1ED.4010907@cosmosbay.com>
	<91bdcedb0903172050td2ef895he48168987ad94472@mail.gmail.com>
	<alpine.WNT.2.00.0903181016120.5116@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6952658959122437844=="
Cc: e1000-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <dada1@cosmosbay.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.WNT.2.00.0903181016120.5116@jbrandeb-desk1.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============6952658959122437844==
Content-Type: multipart/alternative; boundary=00504502c54cf648cc04656f003d

--00504502c54cf648cc04656f003d
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On Wed, Mar 18, 2009 at 12:24 PM, Brandeburg, Jesse <
jesse.brandeburg@intel.com> wrote:
> On Tue, 17 Mar 2009, Dave Boutcher wrote:
>> Eric, based on your inability to recreate this, I tried on some other
>> hardware I had lying around that has an AMD chipset built-in NIC.
>> I could not recreate the problem on that hardware.  I'm starting to
>> think this is an e1000 problem.  In both the e1000 and e1000e
>> drivers they do the following logic:
>>
>>       /* clear the old settings from the multicast hash table */
>>
>>        for (i = 0; i < mta_reg_count; i++) {
>>                E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
>>                E1000_WRITE_FLUSH();
>>        }
>>
>>        /* load any remaining addresses into the hash table */
>>
>>        for (; mc_ptr; mc_ptr = mc_ptr->next) {
>>                hash_value = e1000_hash_mc_addr(hw, mc_ptr->da_addr);
>>                e1000_mta_set(hw, hash_value);
>>        }
>>
>> There's clearly a window where the NIC doesn't have the multicast
>> addresses loaded.  This may just be broken-as-designed.  If anyone
>> else happens to have some e1000 hardware and wants to see if you
>> can recreate this, I'd be curious.
>>
>> Some other notes just FYI...
>>
>> - RcvbufErrors in /proc/net/snmp doesn't get incremented when this
happens
>> - there are no messages in dmesg
>> - frames get dropped when the program calls exit() and all the sockets
>> get closed
>>   (and multicast joins dropped) as well as when the ADD_MEMBERSHIPs
happen
>> - The problem happens even when adding a sleep(1) in between each of the
>>   ADD_MEMBERSHIP calls.
>
> Interesting, this code has been there for eons (and probably this
> behavior) but that doesn't mean its not a problem.
>
> We are in the process of figuring out if there are any hardware corner
> cases to changing this code (particularly in e1000)
>
> Initial thoughts are:
> 1) kcalloc an array that we then populate with the hash functions, and
>   then program every location only once (never flush)
> 2) only program a single hash value each time a multicast is added (bad
>   because we can't tell the difference in the list since the last time
>   the OS gave us the list)
Hi Jesse, thanks for the response...

If you go back in this thread I had a dead easy unprivileged user-land
testcase
that causes frame loss.  We ran into this in a production environment (and I
kind
of glossed over how long it took to figure out why the hell we were dropping
frames...you can only increase rmem_max so many times ;-)  OTOH not that
many
people use multicast, and even fewer notice a few dropped frames, so the
priority is probably lowish.

On the other other hand, I'm working in the financial trading space these
days,
where Linux is pretty much king....and they're all about multicast.

-- 
Dave B

--00504502c54cf648cc04656f003d--


--===============6952658959122437844==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
--===============6952658959122437844==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--===============6952658959122437844==--
