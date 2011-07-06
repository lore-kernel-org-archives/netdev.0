From: Jon Mason <jdmason@kudzu.us>
Subject: Re: Warning:
 myri10ge/sky2/vxge/r8169/niu/bnx2/bnx2x/igb/e100e/cxgb3/mlx4/tg3/vxge :
 removal of PCI_CAP_ID_EXP
Date: Tue, 5 Jul 2011 22:14:57 -0500
Message-ID: <CAPoiz9whbFYaNddYeg8BjJrsuMV-4+3T3e_CLu-ZZPOSAWNvCg@mail.gmail.com>
References: <1309196346-15749-1-git-send-email-jdmason@kudzu.us>
	<4E0CDF8B.3020505@emulex.com>
	<9c96a4a4-c1e3-4af2-a129-db1ce80a2973@exht1.ad.emulex.com>
	<BANLkTi=BCC3PO_LecW77ht+kBAAVD6=Kgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: nic_swsd@realtek.com, divy@chelsio.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, romieu@fr.zoreil.com,
	mcarlson@broadcom.com, eilong@broadcom.com,
	yevgenyp@mellanox.co.il, Richard Lary <rlary@us.ibm.com>,
	gallatin@myri.com, shemminger@linux-foundation.org,
	"davem@davemloft.net" <davem@davemloft.net>, mchan@broadcom.com
To: James Smart <james.smart@emulex.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <BANLkTi=BCC3PO_LecW77ht+kBAAVD6=Kgw@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, Jul 1, 2011 at 10:28 AM, Jon Mason <jdmason@kudzu.us> wrote:
> On Fri, Jul 1, 2011 at 9:49 AM, James Smart <james.smart@emulex.com> wrot=
e:
>> All,
>>
>> I wanted to communicate a potential warning to those drivers that had a
>> patch submitted to replace config space searches of PCI_CAP_ID_EXP with
>> shorthand options such as is_pcie and pci_is_pcie().
>>
>> Testing with the lpfc driver and AER/EEH identified cases where the
>> short-hand search options would fail on PPC platforms. =A0The only succe=
ssful
>> option in all cases was the explicit search via PCI_CAP_ID_EXP. =A0 Ther=
efore,
>> I recommend that this change not be accepted until the platform level is=
sue
>> can be identified and corrected.
>
> pci_is_pcie checks for a PCI-E capability offset that was determined
> by calling pci_find_capability during the PCI bus walking. =A0Based on
> your description above this should be functionally equivalent. =A0If
> this is not safe, then the PCI bus walking code is most likely busted
> on EEH enabled PPC systems (and that is a BIG problem).
>
> I have e-mailed the PPC and PCI mailing lists to verify the issue.

Per Richard Lary's testing, this is not an issue with the latest kernel.
http://www.spinics.net/lists/linux-pci/msg11350.html

Thanks,
Jon


>
> Thanks,
> Jon
>
>
>>
>> -- james s
>>
>>
>>
>> On 6/30/2011 4:41 PM, James Smart wrote:
>>>
>>> Jon,
>>>
>>> I must NACK this patch to the lpfc driver and recommend that all other
>>> patches
>>> which replace pci_find_capability(pdef, PCI_CAP_ID_EXP) with
>>> "pci_is_pcie(pdev)" are NACK'd as well.
>>>
>>> The reason is due to an issue on PPC platforms whereby use of
>>> "pdev->is_pcie"
>>> and pci_is_pcie() will erroneously fail under some conditions, but
>>> explicit
>>> search for the capability struct via pci_find_capability() is always
>>> successful. =A0 I expect this to be due a shadowing of pci config space=
 in
>>> the
>>> hal/platform that isn't sufficiently built up. =A0We detected this issue
>>> while
>>> testing AER/EEH, and are functional only if the pci_find_capability()
>>> option
>>> is used.
>>>
>>> -- james s
>>>
>>>
>>>
>>> On 6/27/2011 1:39 PM, Jon Mason wrote:
>>>>
>>>> The PCIE capability offset is saved during PCI bus walking. =A0It will
>>>> remove an unnecessary search in the PCI configuration space if this
>>>> value is referenced instead of reacquiring it. =A0Also, pci_is_pcie is=
 a
>>>> better way of determining if the device is PCIE or not (as it uses the
>>>> same saved PCIE capability offset).
>>>>
>>>> Signed-off-by: Jon Mason<jdmason@kudzu.us>
>>>> ---
>>>> =A0 drivers/scsi/lpfc/lpfc_init.c | =A0 =A02 +-
>>>> =A0 1 files changed, 1 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/drivers/scsi/lpfc/lpfc_init.c
>>>> b/drivers/scsi/lpfc/lpfc_init.c
>>>> index 148b98d..9000ad0 100644
>>>> --- a/drivers/scsi/lpfc/lpfc_init.c
>>>> +++ b/drivers/scsi/lpfc/lpfc_init.c
>>>> @@ -3970,7 +3970,7 @@ lpfc_enable_pci_dev(struct lpfc_hba *phba)
>>>> =A0 =A0 =A0 =A0pci_save_state(pdev);
>>>>
>>>> =A0 =A0 =A0 =A0/* PCIe EEH recovery on powerpc platforms needs fundame=
ntal reset
>>>> */
>>>> - =A0 =A0 =A0 if (pci_find_capability(pdev, PCI_CAP_ID_EXP))
>>>> + =A0 =A0 =A0 if (pci_is_pcie(pdev))
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pdev->needs_freset =3D 1;
>>>>
>>>> =A0 =A0 =A0 =A0return 0;
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>>
>>
>

---------------------------------------------------------------------------=
---
All of the data generated in your IT infrastructure is seriously valuable.
Why? It contains a definitive record of application performance, security =

threats, fraudulent activity, and more. Splunk takes this data and makes =

sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-d2d-c2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
