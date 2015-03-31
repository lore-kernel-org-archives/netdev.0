From: Robert Dolca <robert.dolca@gmail.com>
Subject: Re: [linux-nfc] [PATCH 1/8] NFC: NCI: Allow connection close with dev down
Date: Tue, 31 Mar 2015 17:03:42 +0300
Message-ID: <CAFPB+Yc-+1s4Y1iWnnCHWjnk=U5Rq-6Wq-idtakCxju8pvYi4Q@mail.gmail.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
 <1424772112-27399-2-git-send-email-robert.dolca@intel.com> <20150326002925.GA10954@ribalta.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Robert Dolca <robert.dolca@intel.com>, linux-nfc@lists.01.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150326002925.GA10954@ribalta.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 26, 2015 at 2:29 AM, Samuel Ortiz <sameo@linux.intel.com> wrote:
> Hi Robert,
>
> On Tue, Feb 24, 2015 at 12:01:45PM +0200, Robert Dolca wrote:
>> By calling __nci_request instead of nci_request allows the driver to use
>> the function while initializing the device (setup stage)
>>
>> Signed-off-by: Robert Dolca <robert.dolca@intel.com>
>> ---
>>  net/nfc/nci/core.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
>> index 9575a18..c4dd5d8 100644
>> --- a/net/nfc/nci/core.c
>> +++ b/net/nfc/nci/core.c
>> @@ -558,7 +558,7 @@ static void nci_core_conn_close_req(struct nci_dev *ndev, unsigned long opt)
>>
>>  int nci_core_conn_close(struct nci_dev *ndev, u8 conn_id)
>>  {
>> -     return nci_request(ndev, nci_core_conn_close_req, conn_id,
>> +     return __nci_request(ndev, nci_core_conn_close_req, conn_id,
>>                               msecs_to_jiffies(NCI_CMD_TIMEOUT));
> You're fixing your problem by removing the NCI request serialization and
> removing the check for your device being UP.
> I assume you need to open and close a proprietary connection from your
> setup hook ? Then please extend nci_request() to check for both NCI_UP
> and NCI_INIT.

You are right, I am opening and closing a connection from the setup
function. The setup is called by nci_open_device. At the beginning of
nci_open_device, req_lock is being acquired and it is release at the
end of the function. That means that when setup is being called
req_lock is acuired. As you said I can modify nci_request to check for
NCI_INIT but it tries to acquire req_lock and it can not succeed.

We could use another mutex for nci_request but I am not sure if that
is a good idea.

Regards,
Robert
