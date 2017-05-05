From: Amir Goldstein <amir73il@gmail.com>
Subject: Re: [PATCH v1] ACPI: Switch to use generic UUID API
Date: Fri, 5 May 2017 10:06:06 +0300
Message-ID: <CAOQ4uxjha8_2_HwgdgBN=G-vNytAW5Gk155E9z8OWyFiGNEZVw@mail.gmail.com>
References: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com> <CAPcyv4jzD0MEBRNTwTokVzgdDWas682ArUjRAGT1hp=QRE8Pjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        tpmdd-devel@lists.sourceforge.net, intel-gfx@lists.freedesktop.org,
        nouveau@lists.freedesktop.org, linux-input@vger.kernel.org,
        iommu@lists.linux-foundation.org, linux-mmc@vger.kernel.org,
        Netdev <netdev@vger.kernel.org>, linux-pci@vger.kernel.org,
        USB list <linux-usb@vger.kernel.org>,
        alsa-devel@alsa-project.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Rafael J . Wysocki" <rjw@rjwysocki.net>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        Borislav Petkov <bp@suse.de>,
        Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
        Jani Nikula <jani.nikula@linux.intel.com>,
        Ben Skeggs <bskeggs@redhat.com>,
        Benjamin Tissoires <benjamin.tissoires@redhat.com>,
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <CAPcyv4jzD0MEBRNTwTokVzgdDWas682ArUjRAGT1hp=QRE8Pjg@mail.gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 5, 2017 at 9:20 AM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Thu, May 4, 2017 at 2:21 AM, Andy Shevchenko
> <andriy.shevchenko@linux.intel.com> wrote:
>> acpi_evaluate_dsm() and friends take a pointer to a raw buffer of 16
>> bytes. Instead we convert them to use uuid_le type. At the same time we
>> convert current users.
>>
>> acpi_str_to_uuid() becomes useless after the conversion and it's safe to
>> get rid of it.
>>
>> The conversion fixes a potential bug in int340x_thermal as well since
>> we have to use memcmp() on binary data.
>>
>> Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
>> Cc: Mika Westerberg <mika.westerberg@linux.intel.com>
>> Cc: Borislav Petkov <bp@suse.de>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Amir Goldstein <amir73il@gmail.com>
>> Cc: Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>
>> Cc: Jani Nikula <jani.nikula@linux.intel.com>
>> Cc: Ben Skeggs <bskeggs@redhat.com>
>> Cc: Benjamin Tissoires <benjamin.tissoires@redhat.com>
>> Cc: Joerg Roedel <joro@8bytes.org>
>> Cc: Adrian Hunter <adrian.hunter@intel.com>
>> Cc: Yisen Zhuang <yisen.zhuang@huawei.com>
>> Cc: Bjorn Helgaas <bhelgaas@google.com>
>> Cc: Zhang Rui <rui.zhang@intel.com>
>> Cc: Felipe Balbi <balbi@kernel.org>
>> Cc: Mathias Nyman <mathias.nyman@intel.com>
>> Cc: Heikki Krogerus <heikki.krogerus@linux.intel.com>
>> Cc: Liam Girdwood <lgirdwood@gmail.com>
>> Cc: Mark Brown <broonie@kernel.org>
>> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> [..]
>> diff --git a/drivers/acpi/nfit/core.c b/drivers/acpi/nfit/core.c
>> index 0f7982a1caaf..bd3e45ede056 100644
>> --- a/drivers/acpi/nfit/core.c
>> +++ b/drivers/acpi/nfit/core.c
>> @@ -74,11 +74,11 @@ struct nfit_table_prev {
>>         struct list_head flushes;
>>  };
>>
>> -static u8 nfit_uuid[NFIT_UUID_MAX][16];
>> +static uuid_le nfit_uuid[NFIT_UUID_MAX];
>>
>> -const u8 *to_nfit_uuid(enum nfit_uuids id)
>> +const uuid_le *to_nfit_uuid(enum nfit_uuids id)
>>  {
>> -       return nfit_uuid[id];
>> +       return &nfit_uuid[id];
>>  }
>>  EXPORT_SYMBOL(to_nfit_uuid);
>>
>> @@ -207,7 +207,7 @@ int acpi_nfit_ctl(struct nvdimm_bus_descriptor *nd_desc, struct nvdimm *nvdimm,
>>         u32 offset, fw_status = 0;
>>         acpi_handle handle;
>>         unsigned int func;
>> -       const u8 *uuid;
>> +       const uuid_le *uuid;
>>         int rc, i;
>>
>>         func = cmd;
>> @@ -394,7 +394,7 @@ int nfit_spa_type(struct acpi_nfit_system_address *spa)
>>         int i;
>>
>>         for (i = 0; i < NFIT_UUID_MAX; i++)
>> -               if (memcmp(to_nfit_uuid(i), spa->range_guid, 16) == 0)
>> +               if (!uuid_le_cmp_pp(to_nfit_uuid(i), (uuid_le *)spa->range_guid))
>
> What is _cmp_pp? Why not _compare?
>

I second that.

Andy,

I much rather that you sort out uuid helpers in a way that will
satisfy the filesystem
needs (just provide the helpers don't need to convert filesystems code).

The only reason I took a swing at hoisting the xfs uuid helpers is
because it didn't
seem like your proposal was going to be posted soon or wasn't going to satisfy
the filesystems use case.

My opinion now, is that your suggestion is probably much closer to the real deal
than mine.

IMO, you should acknowledge that the common use case for filesystems is
to handle an opaque char[16] which most likely holds a uuid_be and you
should provide 'neutral' helpers to satisfy this use case.

The simplest would be to typedef uuid_t to struct uuid_be and to name 'neutral'
helpers' uuid_cmp/uuid_copy(uuid_t *, uuid_t *), similar to my proposal.

I think with this semantic change, our proposals can reach common grounds
and satisfy a wider group of users (i.e. filesystem developers).

Christoph also suggested a similar treatment to typedef guid_t to
struct uuid_le.
I don't know the use cases enough to comment on that.

Cheers,
Amir.
