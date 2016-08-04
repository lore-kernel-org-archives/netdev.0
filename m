From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net] bridge: Fix problems around fdb entries
 pointing to the bridge device
Date: Thu, 4 Aug 2016 17:15:22 +0900
Message-ID: <ca69126a-3387-7499-c02c-55ba10f0793b@lab.ntt.co.jp>
References: <1470276679-5533-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<57A2ED94.2020709@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <57A2ED94.2020709@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 2016/08/04 16:24, Roopa Prabhu wrote:
> On 8/3/16, 7:11 PM, Toshiaki Makita wrote:
>> Adding fdb entries pointing to the bridge device uses fdb_insert(),
>> which lacks various checks and does not respect added_by_user flag.
>>
>> As a result, some inconsistent behavior can happen:
>> * Adding temporary entries succeeds but results in permanent entries.
> 
> IIRC this is not specific to fdb entries on the bridge device. all temp
> fdb entries via iproute2 result in permanent entries. thats why 'dynamic'
> was added.

Sorry for confusing you, I meant "temp" (i.e., "static") of bridge fdb
command.
"temp", "dynamic" and "use" should not result in "permanent".

>> * Same goes for "dynamic" and "use".
> This patch seems to not allow dynamic and use entries
> on the bridge device. I don't see a strong use-case to
> allow them, but any reason you want to add the restriction now ?

Because dynamic fdb entries pointing the bridge device cannot be
created. So it is prohibited. I cannot find other appropriate behavior
about this.
Or are you suggesting local entries with aging supported or something
like that?

>> * Changing mac address of the bridge device causes deletion of
>>   user-added entries.
> unless I am missing something, this does not seem to be related to the
> external fdb entry on the bridge device.

Yes this is related to manually-added fdb entries on the bridge device.
When manual addition of fdb pointing the bridge device was introduced,
we should have set added_by_user on adding the entry and modify
br_fdb_change_mac_address() to respect the flag, but both were not done.

> 
>> * Replacing existing entries looks successful from userspace but actually
>>   not, regardless of NLM_F_EXCL flag.
> curious about this one. I will try it, but if you have an example that
> will help.

Before:
# bridge fdb add 12:34:56:78:90:ab dev enp3s0 master
# bridge fdb add 12:34:56:78:90:ab dev br0; echo $?
0
# bridge fdb show
...
12:34:56:78:90:ab dev enp3s0 master br0 permanent

# bridge fdb replace 12:34:56:78:90:ab dev br0; echo $?
0
# bridge fdb show
...
12:34:56:78:90:ab dev enp3s0 master br0 permanent

After:
# bridge fdb add 12:34:56:78:90:ab dev enp3s0 master
# bridge fdb add 12:34:56:78:90:ab dev br0; echo $?
RTNETLINK answers: File exists
255

# bridge fdb replace 12:34:56:78:90:ab dev br0; echo $?
0
# bridge fdb show
...
12:34:56:78:90:ab dev br0 master br0 permanent

-- 
Toshiaki Makita
